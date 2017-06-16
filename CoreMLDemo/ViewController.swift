//
//  ViewController.swift
//  CoreMLDemo
//
//  Created by dashuios126 on 2017/6/15.
//  Copyright © 2017年 dashuios126. All rights reserved.
//

import UIKit

import CoreML
import Vision


class ViewController: UIViewController {

    @IBOutlet weak var iocn_img: UIImageView!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var matching: UILabel!
    
    var imagePickController: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func click(_ sender: UIButton) {
        imagePickController = UIImagePickerController()
        imagePickController.sourceType = .photoLibrary
        imagePickController.allowsEditing = true
        imagePickController.delegate = self
        present(imagePickController, animated: true, completion: nil)
    }
   
    // 识别图片
    @IBAction func identifyImage(_ sender: UIButton) {
        
        /*
         * version  高性能的图像分析和图像识别,这部分用于人脸追踪,人脸识别,文本识别,区域识别,二维码识别,物体追踪,图像识别等
         * Nattural Language processing  自然语言的处理. 用于语言的识别,分词,词性还原,词性判定
         * GamePlayKit  游戏制作,构建游戏.  用于常见的游戏行为,如随机数生成,人工智能,寻路和代理行为
         */
        
        /*
         * 这里使用的是 Resnet50 model,将下载好的model加入到工程中,会自动生成可用的文件
         * 分成三部分: 第一部分是基本的描述,第二部分Model对应生成的source,点击 Resnet50 末尾的小箭头进入Resnet50.h 文件 可以看到对应 Model的类和方法:
         *  一共生成了三个类:Resnet50,Resnet50Input,Resnet50Output
         *  Resnet50Output 用于输出鉴定结果
         *  Resnet50Input  用于你需要识别的参数,需要传入的参数是CVPixelBufferRef,这里直接使用Vision将图片转换成可支持的数据类型
         * 
         */
        let resnetModel = Resnet50()
        let image = iocn_img.image
        
        do {
            let vnCoreModel = try VNCoreMLModel(for: resnetModel.model)
            let vnCoreMlRequest = VNCoreMLRequest(model: vnCoreModel) { (request, error) in
                var confidence: VNConfidence = 0.0
                var tempClassification: VNClassificationObservation?
                let result = request.results
                
                for classification in result! {
                    if (((classification as? VNClassificationObservation)?.confidence)! > confidence){
                        confidence = (classification as AnyObject).confidence;
                        tempClassification = classification as? VNClassificationObservation;
                    }
                }
                /*
                 * identifier   识别的结果
                 * confidence   识别率
                 */
                self.result.text = ("识别结果\(tempClassification?.identifier ?? " ")")
//                    [NSString stringWithFormat:@"识别结果:%@",tempClassification.identifier];
                self.matching.text = ("匹配率:\(String(describing: tempClassification!.confidence))")
//                    [NSString stringWithFormat:@"匹配率:%@",@(tempClassification.confidence)];
            }
            
            let vnImageRequestHandler = VNImageRequestHandler(cgImage: (image?.cgImage)!, options: [:])
            
            do {
                // 主要的开始识别方法,识别成功会回调 VNCoreMLRequest方法的 completionHandler,返回的结果是VNClassificationObservation数组,每一个都是VNClassificationObservation都是识别结果
                try vnImageRequestHandler.perform([vnCoreMlRequest])
            } catch  {
                    print(error.localizedDescription)
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 选取的信息都在info中,info是一个字典
        /*
             UIImagePickerControllerMediaType       指定用户选择的媒体类型
             UIImagePickerControllerOriginalImage   原始图片
             UIImagePickerControllerEditedImage     修改后的图片
             UIImagePickerControllerCropRect        裁剪尺寸
             UIImagePickerControllerMediaURL        媒体的URL
             UIImagePickerControllerReferenceURL    原件的URL
             UIImagePickerControllerMediaMetadata   当来数据来源是照相机的时候这个值才有效
         */
  
        
        let image = info[UIImagePickerControllerEditedImage]
        iocn_img.image = (image as! UIImage)
        picker.dismiss(animated: true, completion: nil)
    }
}

