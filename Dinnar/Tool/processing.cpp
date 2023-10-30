#include "processing.h"

float sigmoid_function(float a)
{
    float b = 1. / (1. + exp(-a));
    return b;
}

cv::Mat letterbox(cv::Mat& img, std::vector<float>& paddings, std::vector<int> new_shape)
{
    // Get current image shape [height, width]
    // Refer to https://github.com/ultralytics/yolov5/blob/master/utils/augmentations.py#L111

    int img_h = img.rows;
    int img_w = img.cols;

    // Compute scale ratio(new / old) and target resized shape
    float scale = std::min(new_shape[1] * 1.0 / img_h, new_shape[0] * 1.0 / img_w);
    int resize_h = int(round(img_h * scale));
    int resize_w = int(round(img_w * scale));
    paddings[0] = scale;

    // Compute padding
    int pad_h = new_shape[1] - resize_h;
    int pad_w = new_shape[0] - resize_w;


    // Resize and pad image while meeting stride-multiple constraints
    cv::Mat resized_img;
    cv::resize(img, resized_img, cv::Size(resize_w, resize_h));

    // divide padding into 2 sides
    float half_h = pad_h * 1.0 / 2;
    float half_w = pad_w * 1.0 / 2;
    paddings[1] = half_h;
    paddings[2] = half_w;

    // Compute padding boarder
    int top = int(round(half_h - 0.1));
    int bottom = int(round(half_h + 0.1));
    int left = int(round(half_w - 0.1));
    int right = int(round(half_w + 0.1));
    //cv::warpa
    // Add border
    cv::copyMakeBorder(resized_img, resized_img, top, bottom, left, right, 0, cv::Scalar(114, 114, 114));
    cv::imwrite("test.jpg", resized_img);

    return resized_img;

}

cv::Mat letterbox_test(cv::Mat& img, std::vector<float>& paddings, std::vector<int> new_shape)
{
    // Get current image shape [height, width]
    // Refer to https://github.com/ultralytics/yolov5/blob/master/utils/augmentations.py#L111

    int img_h = img.rows;
    int img_w = img.cols;

    // Compute scale ratio(new / old) and target resized shape
    float scale = std::min(new_shape[1] * 1.0 / img_h, new_shape[0] * 1.0 / img_w);
    int resize_h = int(round(img_h * scale));
    int resize_w = int(round(img_w * scale));
    paddings[0] = scale;

    // Compute padding
    int pad_h = new_shape[1] - resize_h;
    int pad_w = new_shape[0] - resize_w;

    // divide padding into 2 sides
    float half_h = pad_h * 1.0 / 2;
    float half_w = pad_w * 1.0 / 2;
    paddings[1] = half_h;
    paddings[2] = half_w;


    // Resize and pad image while meeting stride-multiple constraints
    cv::Mat resized_img;

    float b1 = (new_shape[0]+scale-1) * 0.5 - scale * img_w * 0.5;
    float b2 = (new_shape[1]+scale-1) * 0.5 - scale * img_h * 0.5;

    float m[2][3] = {scale, 0, b1,
                    0, scale, b2};

    cv::Mat M = cv::Mat(2,3,CV_32F,m);
    cv::Size new_size = cv::Size(new_shape[0], new_shape[1]);

    cv::warpAffine(img, resized_img, M, new_size, 1, 0, cv::Scalar(114, 114, 114));
    
    cv::imwrite("warpaffine.jpg", resized_img);

    /*
    cv::Mat restore_img;
    float m1[2][3] = { 1./scale, 0, -b1/scale,
                       0, 1./scale, -b2/scale};
    cv::Mat M1 = cv::Mat( 2, 3, CV_32F, m1 );
    cv::Size ori_size = cv::Size(img_w, img_h);
    cv::warpAffine(resized_img, restore_img, M1, ori_size);

    cv::imwrite("restore.jpg", restore_img);
    */

    return resized_img;

}

std::vector<int> boxProcessing(cv::Mat detect_buffer,
                               std::vector<float> paddings, 
                               std::vector<cv::Rect>& boxes,
                               std::vector<int>& class_ids,
                               std::vector<float>& class_scores,
                               std::vector<float>& confidences,
                               std::vector<cv::Mat>& masks,
                               float conf_threshold,
                               float nms_threshold) {

    // ---------------- Post-process the inference result -----------
    // cx,cy,w,h,confidence,c1,c2,...c80
    float scale = paddings[0];
    for (int i = 0; i < detect_buffer.rows; i++) {
        float confidence = detect_buffer.at<float>(i, 4);
        if (confidence < conf_threshold) {
            continue;
        }
        cv::Mat classes_scores = detect_buffer.row(i).colRange(5, 85);
        cv::Point class_id;
        double score;
        //取最大值score及指针
        cv::minMaxLoc(classes_scores, NULL, &score, NULL, &class_id);

        // class score: 0~1
        if (score > 0.25)
        {
            cv::Mat mask = detect_buffer.row(i).colRange(85, 117);
            float cx = detect_buffer.at<float>(i, 0);
            float cy = detect_buffer.at<float>(i, 1);
            float w = detect_buffer.at<float>(i, 2);
            float h = detect_buffer.at<float>(i, 3);
            int left = static_cast<int>((cx - 0.5 * w - paddings[2]) / scale);
            int top = static_cast<int>((cy - 0.5 * h - paddings[1]) / scale);
            int width = static_cast<int>(w / scale);
            int height = static_cast<int>(h / scale);
            cv::Rect box(left, top, width, height);

            boxes.push_back(box);
            class_ids.push_back(class_id.x);
            class_scores.push_back(score);
            confidences.push_back(confidence);
            masks.push_back(mask);
        }
    }
    // NMS
    std::vector<int> indices;
    cv::dnn::NMSBoxes(boxes, confidences, conf_threshold, nms_threshold, indices);
    return indices;
}

std::vector<cv::Mat> maskProcessing(cv::Mat img,
                                    std::vector<int> indices,
                                    cv::Mat proto_buffer,
                                    std::vector<float> paddings,
                                    std::vector<cv::Rect> boxes,
                                    std::vector<cv::Mat> masks,
                                    std::vector<int> new_shape
                                    ) {
            
    cv::RNG rng;
    float scale = paddings[0];
    std::vector<cv::Mat> processed_masks;
    for (size_t i = 0; i < indices.size(); i++) {
        cv::Mat rgb_mask = cv::Mat::zeros(img.size(), img.type());
        int index = indices[i];
        cv::Rect box = boxes[index];
        int x1 = std::max(0, box.x);
        int y1 = std::max(0, box.y);
        int x2 = std::max(0, box.br().x);
        int y2 = std::max(0, box.br().y);

        cv::Mat m = masks[index] * proto_buffer;
        for (int col = 0; col < m.cols; col++) {
            m.at<float>(0, col) = sigmoid_function(m.at<float>(0, col));
        }
        cv::Mat m1 = m.reshape(1, 160); // 1x25600 -> 160x160

        int mx1 = std::max(0, int((x1 * scale + paddings[2]) * 0.25));
        int mx2 = std::max(0, int((x2 * scale + paddings[2]) * 0.25));
        int my1 = std::max(0, int((y1 * scale + paddings[1]) * 0.25));
        int my2 = std::max(0, int((y2 * scale + paddings[1]) * 0.25));
        cv::Mat mask_roi = m1(cv::Range(my1, my2), cv::Range(mx1, mx2));
        cv::Mat rm, det_mask;
        cv::resize(mask_roi, rm, cv::Size(x2 - x1, y2 - y1));
        for (int r = 0; r < rm.rows; r++) {
            for (int c = 0; c < rm.cols; c++) {
                float pv = rm.at<float>(r, c);
                if (pv > 0.5) {
                    rm.at<float>(r, c) = 1.0;
                }
                else {
                    rm.at<float>(r, c) = 0.0;
                }
            }
        }
        rm = rm * rng.uniform(0, 255);
        rm.convertTo(det_mask, CV_8UC1);
        if ((y1 + det_mask.rows) >= img.rows) {
            y2 = img.rows - 1;
        }
        if ((x1 + det_mask.cols) >= img.cols) {
            x2 = img.cols - 1;
        }

        cv::Mat mask = cv::Mat::zeros(cv::Size(img.cols, img.rows), CV_8UC1);        
        det_mask(cv::Range(0, y2 - y1), cv::Range(0, x2 - x1)).copyTo(mask(cv::Range(y1, y2), cv::Range(x1, x2)));      

        add(rgb_mask, cv::Scalar(rng.uniform(0, 255), rng.uniform(0, 255), rng.uniform(0, 255)), rgb_mask, mask);

        processed_masks.push_back(rgb_mask);
    }
    return processed_masks;
}

