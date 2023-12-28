#pragma once
#include <opencv2/opencv.hpp>
#include <iostream>
#include <string>

//#include <openvino/openvino.hpp>


float sigmoid_function(float a);

cv::Mat letterbox(cv::Mat& img,
                  std::vector<float>& paddings, 
                  std::vector<int> new_shape = {640,640});

cv::Mat letterDetectbox(cv::Mat& img,
                  std::vector<float>& paddings,
                  std::vector<int> new_shape = {2048,2048});

//参数中返回的框等为所有检测结果,函数返回的数组记录了所有检测结果中有效的序号
std::vector<int> boxProcessing(cv::Mat detect_buffer,
                               std::vector<float> paddings,
                               std::vector<cv::Rect>& boxes,
                               std::vector<int>& class_ids,
                               std::vector<float>& class_scores,
                               std::vector<float>& confidences,
                               std::vector<cv::Mat>& masks,
                               float conf_threshold = 0.25,
                               float nms_threshold = 0.5);

std::vector<int> boxDetectProcessing(cv::Mat detect_buffer,
                               std::vector<float> paddings,
                               std::vector<cv::Rect2d>& boxes,
                               std::vector<int>& class_ids,
                               std::vector<float>& class_scores,
                               std::vector<float>& confidences,
                               std::vector<cv::Mat>& masks);
//返回处理后的掩膜
std::vector<cv::Mat> maskProcessing(cv::Mat img,
                                    std::vector<int> indices,
                                    cv::Mat proto_buffer,
                                    std::vector<float> paddings,
                                    std::vector<cv::Rect> boxes,
                                    std::vector<cv::Mat> masks,
                                    std::vector<int> new_shape = {640,640});

