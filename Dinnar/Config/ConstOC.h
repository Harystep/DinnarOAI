//
//  ConstOC.h
//  Dinnar
//
//  Created by Lizheng Pang on 2023/6/25.
//

#ifndef ConstOC_h
#define ConstOC_h
std::vector<cv::Scalar> colors = { cv::Scalar(0, 0, 255, 255) , cv::Scalar(0, 255, 0, 255) , cv::Scalar(255, 0, 0, 255) ,
                                   cv::Scalar(255, 255, 0, 255) , cv::Scalar(0, 255, 255, 255) , cv::Scalar(255, 0, 255, 255) };
const std::vector<std::string> class_names = {
    "person", "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat", "traffic light",
    "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat", "dog", "horse", "sheep", "cow",
    "elephant", "bear", "zebra", "giraffe", "backpack", "umbrella", "handbag", "tie", "suitcase", "frisbee",
    "skis", "snowboard", "sports ball", "kite", "baseball bat", "baseball glove", "skateboard", "surfboard",
    "tennis racket", "bottle", "wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple",
    "sandwich", "orange", "broccoli", "carrot", "hot dog", "pizza", "donut", "cake", "chair", "couch",
    "potted plant", "bed", "dining table", "toilet", "tv", "laptop", "mouse", "remote", "keyboard", "cell phone",
    "microwave", "oven", "toaster", "sink", "refrigerator", "book", "clock", "vase", "scissors", "teddy bear",
    "hair drier", "toothbrush" };

#endif /* ConstOC_h */
