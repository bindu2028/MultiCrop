# ML Model Training Phase - Complete Technical Review Guide

## 1. Objective of the ML Pipeline

The ML component is designed to classify plant leaf diseases from images and return:
- disease label
- confidence score
- crop-aware prediction context

The training system supports:
- single-dataset training
- multi-crop per-model training
- an improved transfer-learning tomato pipeline
- per-crop evaluation with class-level metrics

---

## 2. Datasets Used

### 2.1 Dataset sources present in the project
- `dataset/raw/PlantVillage_Tomato`
- `dataset/processed`
- `dataset/multicrop`

### 2.2 Effective training datasets

#### A. Generic split dataset
Used by `model/src/train.py` (default):
- root format: `train/`, `val/`, `test/`
- classes inferred from folder names
- current `dataset/processed/train` classes:
  - Bacterial Spot
  - Early Blight
  - Healthy
  - Late Blight
  - Septoria Leaf Spot
  - Yellow Leaf Curl Virus

#### B. Multi-crop dataset
Used by `model/src/train_all_crops.py` and `model/src/train_all_crops_colab.py`:
- one folder per crop under `dataset/multicrop`
- each crop folder must contain `Train/Val/Test` (or lowercase variants)
- detected crop folders:
  - Apple
  - Bell Pepper
  - Cherry
  - Corn (Maize)
  - Grape
  - Peach
  - Potato
  - Strawberry
  - Tomato

#### C. Tomato-focused dataset
Used by `model/src/train_tomato_improved.py` (default root):
- `dataset/multicrop/Tomato`

### 2.3 Final class labels used in artifacts
From `model/artifacts/class_names_*.json`:
- Apple: 4 classes
- Bell Pepper: 2 classes
- Cherry: 2 classes
- Corn Maize: 4 classes
- Grape: 4 classes
- Peach: 2 classes
- Potato: 3 classes
- Strawberry: 2 classes
- Tomato: 6 classes

---

## 3. Data Preprocessing and Input Pipeline

Implemented mainly in `model/src/train.py` and reused in orchestrated runs.

### 3.1 Directory parsing rules
- split folders are resolved case-insensitively (`train/Train/TRAIN` etc.)
- classes are validated across train/val/test before training
- class order is either:
  - provided manually via `--class_names`, or
  - inferred from train split and sorted alphabetically

### 3.2 TensorFlow input pipeline
- API: `tf.keras.utils.image_dataset_from_directory`
- label mode: integer labels (`label_mode='int'`)
- image size: default `224 x 224`
- batch size: default `32`
- train shuffle: enabled with `seed=42`
- val/test shuffle: disabled
- prefetch: `tf.data.AUTOTUNE` for better throughput

---

## 4. Model Architectures

## 4.1 Primary architecture (used in current per-crop saved models)
Defined in `model/src/train.py`: custom CNN

Architecture:
1. Input `(224, 224, 3)`
2. Data augmentation:
   - RandomFlip(horizontal)
   - RandomRotation(0.08)
   - RandomZoom(0.12)
3. Rescaling `1/255`
4. Conv block stack:
   - Conv2D(32) + MaxPool
   - Conv2D(64) + MaxPool
   - Conv2D(128) + MaxPool
   - Conv2D(256) + MaxPool
5. Flatten
6. Dense(256, relu)
7. Dropout(0.3)
8. Dense(num_classes, softmax)

Compilation:
- Optimizer: Adam, lr = `1e-3`
- Loss: SparseCategoricalCrossentropy
- Metric: Accuracy

### 4.2 Improved architecture (tomato transfer learning path)
Defined in `model/src/train_tomato_improved.py`:
- Base model: `EfficientNetB0` (ImageNet pretrained)
- Augmentations: flip, rotation, zoom, contrast, translation
- Head:
  - GlobalAveragePooling2D
  - Dropout(0.4)
  - Dense(256, relu)
  - Dropout(0.3)
  - Dense(num_classes, softmax)

Training strategy:
- Stage 1: frozen backbone, train classifier head
- Stage 2: unfreeze partial backbone from `fine_tune_at`, train with low lr

Class imbalance handling:
- computes class weights from training image counts
- uses class weights in both training stages

Note:
- this improved script exists and is production-ready in code,
- but current saved model files in `model/saved_model` are the standard per-crop naming set.

---

## 5. Training Strategy and Hyperparameters

### 5.1 Standard training (`train.py`)
Defaults:
- epochs: `12`
- img_size: `224`
- batch_size: `32`

Callbacks:
- EarlyStopping on `val_accuracy` (patience 4, restore best)
- ReduceLROnPlateau on `val_loss` (factor 0.5, patience 2)
- ModelCheckpoint saving best model by `val_accuracy`

### 5.2 Multi-crop orchestration (`train_all_crops.py`)
Defaults:
- epochs: `15`
- img_size: `224`
- batch_size: `32`

Behavior:
- discovers each crop directory with Train/Val/Test
- calls `train.py` once per crop via subprocess
- saves separate model + artifacts per crop
- supports `--skip_existing`

---

## 6. Training Outputs and Artifacts

### 6.1 Saved model files
Stored in `model/saved_model`:
- `plant_disease_apple.h5`
- `plant_disease_bell_pepper.h5`
- `plant_disease_cherry.h5`
- `plant_disease_corn_maize.h5`
- `plant_disease_grape.h5`
- `plant_disease_peach.h5`
- `plant_disease_potato.h5`
- `plant_disease_strawberry.h5`
- `plant_disease_tomato.h5`
- plus generic `plant_disease_model.h5`

### 6.2 Label artifacts
Per-crop class mapping files in `model/artifacts`:
- `class_names_<crop>.json`

### 6.3 Metrics/history artifacts
The training scripts write:
- training history json
- test metrics json
- class names json

---

## 7. Evaluation Pipeline

Implemented in `model/src/evaluate_all_crops.py`.

For each crop model:
1. load model file
2. load class labels from artifacts (or infer from test dir)
3. run predictions on test split
4. compute confusion matrix
5. compute per-class metrics:
   - precision
   - recall
   - f1
   - support
   - TP, FP, FN, TN
6. write outputs:
   - `confusion_matrix_<crop>.csv`
   - `classification_report_<crop>.json`
   - `evaluation_summary.json`

This is a strong technical point: evaluation is class-wise, not just one aggregate accuracy number.

---

## 8. Data Quality Verification Step

`model/src/verify_dataset.py` performs:
- dataset structure checks for expected splits/classes
- per-class image counts
- random sample visualization with matplotlib

This reduces silent data-structure errors before training.

---

## 9. Inference-Time Consistency with Training

In `backend/app/services/model_service.py`:
- crop models are auto-discovered from `model/saved_model`
- class labels are loaded from `model/artifacts/class_names_<crop>.json`
- model output dimension is validated against class label count
- if mismatch, inference raises an error (prevents wrong predictions)

Additionally, inference applies:
- temperature scaling
- smoothing epsilon
- ambiguity detection for close top-2 predictions

This is a deployment-focused confidence calibration layer.

---

## 10. Why These Architecture Choices

### Why start with custom CNN?
- fast to build
- interpretable
- lower complexity for per-crop small-class tasks
- easy debugging and reproducibility

### Why add transfer learning path?
- better generalization potential
- pretrained visual features from ImageNet
- improved performance under limited data
- supports class imbalance via weighting

### Why per-crop models instead of one giant model?
- simpler label spaces per model
- easier model management for crop-specific disease classes
- less cross-crop confusion in early project phase

---

## 11. Likely Technical-Round Questions with Answers

### Q1. What dataset format does your pipeline require?
A: Directory-based split format with train/val/test and class subfolders under each split.

### Q2. How are class labels determined?
A: Either from explicit `--class_names` or inferred from train folders, then saved in class artifact files for stable inference mapping.

### Q3. What is your base image resolution and batch size?
A: Default image size is 224x224 and batch size is 32.

### Q4. What architecture did you use for production training?
A: A custom CNN with four Conv+Pool blocks, dense head, dropout, and softmax output.

### Q5. Do you have a transfer learning variant?
A: Yes, `train_tomato_improved.py` uses EfficientNetB0 with two-stage fine-tuning.

### Q6. How do you avoid overfitting?
A: Data augmentation, dropout, EarlyStopping, and LR scheduling.

### Q7. How do you handle class imbalance?
A: In improved tomato training, class weights are computed from training counts and passed to model.fit.

### Q8. How do you evaluate model quality?
A: Test-set evaluation plus confusion matrix and class-wise precision/recall/f1 metrics.

### Q9. How do you guarantee inference label correctness?
A: At inference, class labels are loaded from artifacts and validated against model output dimensions.

### Q10. Why multiple models (per crop)?
A: It simplifies classification space and improves maintainability for crop-specific disease sets.

### Q11. What are your current ML limitations?
A: Full metrics artifacts may need rerun for latest checkpoints, and formal experiment tracking/versioning can be improved.

### Q12. What would be your next ML improvements?
A:
- unify experiment tracking (W&B/MLflow)
- add k-fold validation where practical
- tune thresholds/calibration per crop
- compare transfer-learning variants across all crops
- add model version registry and rollback strategy

---

## 12. 30-Second Interview Summary

We built a crop-aware plant disease classification pipeline using TensorFlow. The core production path trains one CNN model per crop from folder-structured train/val/test datasets at 224x224 resolution, with augmentation, early stopping, LR scheduling, and per-crop artifact generation. We also implemented an improved transfer-learning tomato pipeline using EfficientNetB0 with two-stage fine-tuning and class weights. Evaluation includes confusion matrices and class-wise precision/recall/f1, and inference enforces strict class-label consistency using stored artifacts.
