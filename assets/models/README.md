# Detection model

`detect.tflite` is not in this repository. Download instructions, licenses, and the expected output layout are in the project README and in the app under Model setup.

`labelmap_ssd_mobilenet_v1.txt` is `labelmap.txt` from the TensorFlow archive `coco_ssd_mobilenet_v1_1.0_quant_2018_06_29.zip`. That archive is published with the TensorFlow models under the Apache License 2.0. The line number is the class id, including the `???` placeholder rows. Do not insert lines.

`model_config.json` matches that SSD MobileNet checkpoint. Change it when you switch to EfficientDet-Lite.
