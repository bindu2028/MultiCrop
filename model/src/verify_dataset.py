"""Dataset structure verification for Tomato plant disease classification.

Expected layout (Google Colab style):
/content/Tomato/
  Train/
  Test/
  Val/
Each split contains these class folders:
- Bacterial Spot
- Early Blight
- Late Blight
- Healthy
- Septoria Leaf Spot
- Yellow Leaf Curl Virus
"""

from __future__ import annotations

import argparse
import random
from pathlib import Path
from typing import Dict, List

import matplotlib.pyplot as plt
from PIL import Image


EXPECTED_SPLITS = ["Train", "Test", "Val"]
EXPECTED_CLASSES = [
    "Bacterial Spot",
    "Early Blight",
    "Late Blight",
    "Healthy",
    "Septoria Leaf Spot",
    "Yellow Leaf Curl Virus",
]
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def list_image_files(folder: Path) -> List[Path]:
    """Return image files from a folder based on common extensions."""
    return [
        p
        for p in folder.iterdir()
        if p.is_file() and p.suffix.lower() in IMAGE_EXTENSIONS
    ]


def verify_structure(dataset_root: Path) -> None:
    """Print dataset checks and image statistics for each split/class."""
    print("=" * 72)
    print(f"Dataset root: {dataset_root}")
    print("=" * 72)

    if not dataset_root.exists():
        raise FileNotFoundError(f"Dataset path not found: {dataset_root}")

    print(f"Number of classes (expected): {len(EXPECTED_CLASSES)}")
    print(f"Classes: {', '.join(EXPECTED_CLASSES)}")

    for split in EXPECTED_SPLITS:
        split_path = dataset_root / split
        print("\n" + "-" * 72)
        print(f"{split} split")
        print("-" * 72)

        if not split_path.exists():
            print(f"[MISSING] {split_path}")
            continue

        total_split_images = 0

        for class_name in EXPECTED_CLASSES:
            class_path = split_path / class_name
            if not class_path.exists():
                print(f"{class_name:<28}: MISSING FOLDER")
                continue

            image_count = len(list_image_files(class_path))
            total_split_images += image_count
            print(f"{class_name:<28}: {image_count}")

        print(f"Total images in {split:<5}: {total_split_images}")


def show_sample_images(dataset_root: Path, split: str = "Train", samples_per_class: int = 1) -> None:
    """Display sample images for each class from a chosen split."""
    split_path = dataset_root / split
    if not split_path.exists():
        print(f"Cannot show samples. Missing split folder: {split_path}")
        return

    num_classes = len(EXPECTED_CLASSES)
    fig, axes = plt.subplots(
        nrows=num_classes,
        ncols=samples_per_class,
        figsize=(4 * samples_per_class, 3 * num_classes),
    )

    # Normalize axes shape for consistent indexing.
    if samples_per_class == 1:
        axes = [[ax] for ax in axes] if num_classes > 1 else [[axes]]

    for row, class_name in enumerate(EXPECTED_CLASSES):
        class_path = split_path / class_name
        if not class_path.exists():
            for col in range(samples_per_class):
                ax = axes[row][col]
                ax.axis("off")
                ax.set_title(f"{class_name}\n(Missing folder)")
            continue

        images = list_image_files(class_path)
        if not images:
            for col in range(samples_per_class):
                ax = axes[row][col]
                ax.axis("off")
                ax.set_title(f"{class_name}\n(No images)")
            continue

        selected = random.sample(images, k=min(samples_per_class, len(images)))

        # If class has fewer images than requested samples, repeat random picks.
        while len(selected) < samples_per_class:
            selected.append(random.choice(images))

        for col in range(samples_per_class):
            ax = axes[row][col]
            img_path = selected[col]

            with Image.open(img_path) as img:
                ax.imshow(img.convert("RGB"))

            ax.axis("off")
            if col == 0:
                ax.set_title(class_name)
            else:
                ax.set_title(f"{class_name} ({col + 1})")

    plt.tight_layout()
    plt.show()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Verify dataset structure and visualize sample images."
    )
    parser.add_argument(
        "--dataset_path",
        type=str,
        default="/content/Tomato",
        help="Root path of dataset (default: /content/Tomato)",
    )
    parser.add_argument(
        "--sample_split",
        type=str,
        default="Train",
        choices=EXPECTED_SPLITS,
        help="Split used for sample visualization.",
    )
    parser.add_argument(
        "--samples_per_class",
        type=int,
        default=1,
        help="Number of sample images to display per class.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    dataset_root = Path(args.dataset_path)

    verify_structure(dataset_root)
    print("\nDisplaying sample images...")
    show_sample_images(
        dataset_root,
        split=args.sample_split,
        samples_per_class=max(1, args.samples_per_class),
    )


if __name__ == "__main__":
    main()
