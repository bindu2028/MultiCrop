import numpy as np

def simulate_scaling(scores, num_classes, temperature, epsilon):
    smoothed_scores = (scores * (1.0 - epsilon)) + (epsilon / num_classes)
    scaled_scores = np.power(smoothed_scores, 1.0 / temperature)
    scaled_scores = scaled_scores / np.sum(scaled_scores)
    
    sorted_indices = np.argsort(scaled_scores)[::-1]
    top_index = int(sorted_indices[0])
    confidence = float(scaled_scores[top_index])
    
    second_confidence = float(scaled_scores[sorted_indices[1]]) if len(sorted_indices) > 1 else 0.0
    
    return confidence, second_confidence

print("Simulation with 4 classes (Apple):")
print("Original parameters (T=2.5, E=0.08):")
for p in [0.99, 0.90, 0.80, 0.70, 0.60, 0.50, 0.40, 0.30]:
    scores = np.array([p, (1.0-p)/3.0, (1.0-p)/3.0, (1.0-p)/3.0])
    conf, sec = simulate_scaling(scores, 4, 2.5, 0.08)
    print(f"  Raw: {p:.2f} -> Conf: {conf:.4f} (Sec: {sec:.4f})")

print("\nNew parameters (T=1.15, E=0.015):")
for p in [0.99, 0.90, 0.80, 0.70, 0.60, 0.50, 0.40, 0.30]:
    scores = np.array([p, (1.0-p)/3.0, (1.0-p)/3.0, (1.0-p)/3.0])
    conf, sec = simulate_scaling(scores, 4, 1.15, 0.015)
    print(f"  Raw: {p:.2f} -> Conf: {conf:.4f} (Sec: {sec:.4f})")

print("\nSimulation with 6 classes (Tomato):")
print("Original parameters (T=2.5, E=0.08):")
for p in [0.99, 0.90, 0.80, 0.70, 0.60, 0.50, 0.40, 0.30]:
    scores = np.array([p, (1.0-p)/5.0, (1.0-p)/5.0, (1.0-p)/5.0, (1.0-p)/5.0, (1.0-p)/5.0])
    conf, sec = simulate_scaling(scores, 6, 2.5, 0.08)
    print(f"  Raw: {p:.2f} -> Conf: {conf:.4f} (Sec: {sec:.4f})")

print("\nNew parameters (T=1.15, E=0.015):")
for p in [0.99, 0.90, 0.80, 0.70, 0.60, 0.50, 0.40, 0.30]:
    scores = np.array([p, (1.0-p)/5.0, (1.0-p)/5.0, (1.0-p)/5.0, (1.0-p)/5.0, (1.0-p)/5.0])
    conf, sec = simulate_scaling(scores, 6, 1.15, 0.015)
    print(f"  Raw: {p:.2f} -> Conf: {conf:.4f} (Sec: {sec:.4f})")
