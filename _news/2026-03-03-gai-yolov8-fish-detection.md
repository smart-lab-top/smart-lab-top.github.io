---
layout: post
title: "GAI-YOLOv8: Precision-Oriented Fish Detection Algorithm for Sonar-Based Conservation Monitoring"
date: 2026-03-03 15:45:00
inline: false
related_posts: false
---

On March 2, 2026, the **SMART Lab** team from Shanghai Ocean University announced a breakthrough in *Fisheries Research* (Volume 296, Article 107701). The team introduced GAI-YOLOv8, a precision-oriented detection model specifically engineered for identifying fish targets in sonar images, addressing critical needs in monitoring the Critically Endangered Chinese sturgeon (Acipenser sinensis).

### Addressing Conservation Challenges

The Chinese sturgeon, a flagship species for aquatic biodiversity conservation in the Yangtze River, has experienced alarming population declines due to habitat degradation and anthropogenic activities. With China planning to release 1 million Chinese sturgeon in 2025 to supplement wild populations, continuous, non-invasive monitoring becomes indispensable for verifying growth status and health assessment. While sonar imaging overcomes the turbidity limitations of optical methods, it faces challenges from complex environmental noise and the need for lightweight algorithms suitable for resource-constrained embedded devices.

### Methodological Innovations

The SMART Lab team developed GAI-YOLOv8, building upon the YOLOv8n architecture with three synergistic innovations:

1. **C2f-GhostDynamicConv Module**: Integrates lightweight Ghost architectures with dynamic convolution to adaptively enhance feature extraction while reducing parameters
2. **ASF-P2 Neck Architecture**: Adds a high-resolution detection layer (P2) to capture fine-grained details crucial for small targets
3. **Inner-CIoU Loss Function**: Optimizes bounding box regression to improve generalization for small-scale objects

### Key Achievements

* **Superior Detection Performance**: GAI-YOLOv8 achieves **80.8% precision**, **80.8% recall**, **84.9% mAP@0.5**, and **40.7% mAP@0.5:0.95**, outperforming baseline YOLOv8n by **4.5%**, **8.0%**, **5.0%**, and **3.3%**, respectively
* **Lightweight Architecture**: With only **1.9 M parameters** (a 37% reduction compared to baseline), the model achieves an exceptional balance between accuracy and efficiency, suitable for resource-constrained embedded devices
* **Comprehensive Dataset**: Validated on a custom dataset of **1,079 sonar images** collected from Chinese sturgeon aquaculture net pens using BlueView M900/220.5-MKII imaging sonar at 2250 kHz
* **Statistical Robustness**: Five-fold cross-validation demonstrated remarkable stability with mean mAP@0.5 of **78.5%** (standard deviation = 0.029, 95% CI: [0.749, 0.821])
* **Comparative Excellence**: Outperformed other YOLO variants (YOLOv5n, YOLOv10n, YOLOv11n) and high-accuracy models (Faster R-CNN, DETR, RT-DETR) in efficiency-accuracy trade-offs

### Implications for Conservation and Fisheries

The proposed GAI-YOLOv8 model offers significant advancement for the conservation of Chinese sturgeon and provides a non-intrusive, high-precision monitoring solution that overcomes optical system limitations in turbid, noise-heavy aquaculture environments. This technical paradigm is transferable to other benthic species in low-visibility waters, with clear future deployment on efficient real-time inference terminals.

This work advances real-time, resource-efficient underwater monitoring, offering a robust tool for ecological conservation and supporting China's ambitious sturgeon conservation and breeding initiatives.

[[Read the paper]](https://authors.elsevier.com/c/1mhPY8MvAu7TRU)