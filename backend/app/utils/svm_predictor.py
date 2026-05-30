#!/usr/bin/env python3
"""
SVM Bioactivity Predictor - Backend Integration
Predicts compound bioactivity from SMILES using trained SVM + MAP4
"""

import joblib
import numpy as np
from rdkit import Chem
from map4 import MAP4 as MAP4Calculator
import logging
import json
from pathlib import Path

logger = logging.getLogger(__name__)

class SVMBioactivityPredictor:
    """Loads trained SVM model and makes predictions"""
    
    def __init__(self, model_dir='model'):
        """
        Initialize predictor with trained artifacts
        
        Args:
            model_dir: Directory containing model files
        """
        self.model_dir = Path(model_dir)
        self.svm_model = None
        self.scaler = None
        self.label_encoder = None
        self.map4_calculator = None
        self.metadata = None
        
        try:
            self._load_model()
            logger.info("✅ SVM Predictor initialized successfully")
        except Exception as e:
            logger.error(f"❌ Failed to initialize SVM Predictor: {str(e)}")
            raise
    
    def _load_model(self):
        """Load all model artifacts from disk"""
        
        # Load SVM model
        svm_path = self.model_dir / 'svm_bioactivity_model.pkl'
        self.svm_model = joblib.load(svm_path)
        logger.info(f"   Loaded SVM model: {svm_path}")
        
        # Load scaler
        scaler_path = self.model_dir / 'scaler.pkl'
        self.scaler = joblib.load(scaler_path)
        logger.info(f"   Loaded scaler: {scaler_path}")
        
        # Load label encoder
        le_path = self.model_dir / 'label_encoder.pkl'
        self.label_encoder = joblib.load(le_path)
        logger.info(f"   Loaded label encoder: {le_path}")
        
        # Initialize MAP4
        self.map4_calculator = MAP4Calculator(radius=2)
        logger.info("   Initialized MAP4 calculator")
        
        # Load metadata
        metadata_path = self.model_dir / 'model_metadata.json'
        with open(metadata_path, 'r') as f:
            self.metadata = json.load(f)
        logger.info(f"   Loaded metadata: {metadata_path}")
    
    def predict(self, smiles, return_confidence=True, return_all_scores=False):
        """
        Predict bioactivity from SMILES structure
        
        Args:
            smiles: SMILES string (e.g., 'CC(=O)Oc1ccccc1C(=O)O')
            return_confidence: Include confidence scores
            return_all_scores: Include all class probabilities
        
        Returns:
            dict with:
                - primary_bioactivity: Most likely bioactivity
                - confidence: Confidence score (-1 to 1 typically)
                - all_predictions: All class scores (optional)
                - success: True if prediction succeeded
        """
        
        try:
            # Validate SMILES
            if not isinstance(smiles, str) or not smiles.strip():
                return {
                    'success': False,
                    'error': 'Invalid SMILES: empty or not a string'
                }
            
            # Parse molecule
            mol = Chem.MolFromSmiles(smiles)
            if mol is None:
                return {
                    'success': False,
                    'error': f'Invalid SMILES: Could not parse "{smiles}"'
                }
            
            # Generate MAP4 fingerprint
            fp = self.map4_calculator.calculate(mol)
            fp_array = np.array([fp])
            
            # Normalize
            fp_normalized = self.scaler.transform(fp_array)
            
            # Predict
            prediction_label = self.svm_model.predict(fp_normalized)[0]
            decision_scores = self.svm_model.decision_function(fp_normalized)[0]
            
            # Get bioactivity name
            primary_bioactivity = self.label_encoder.classes_[prediction_label]
            
            # Confidence (use decision function)
            confidence = float(decision_scores[prediction_label] if len(decision_scores.shape) > 0 else decision_scores)
            
            # Build response
            result = {
                'success': True,
                'smiles': smiles,
                'primary_bioactivity': primary_bioactivity,
                'predicted_class_id': int(prediction_label),
                'confidence': confidence
            }
            
            if return_all_scores:
                all_predictions = {}
                for i, activity in enumerate(self.label_encoder.classes_):
                    score = float(decision_scores[i] if len(decision_scores.shape) > 0 else decision_scores)
                    all_predictions[activity] = score
                result['all_predictions'] = all_predictions
            
            return result
        
        except Exception as e:
            logger.error(f"Prediction error for SMILES '{smiles}': {str(e)}")
            return {
                'success': False,
                'error': str(e),
                'smiles': smiles
            }
    
    def batch_predict(self, smiles_list):
        """
        Predict multiple SMILES at once
        
        Args:
            smiles_list: List of SMILES strings
        
        Returns:
            List of prediction results
        """
        results = []
        for smiles in smiles_list:
            result = self.predict(smiles)
            results.append(result)
        return results
    
    def get_bioactivity_classes(self):
        """Get list of all bioactivity classes the model can predict"""
        return list(self.label_encoder.classes_)
    
    def get_model_info(self):
        """Get information about the trained model"""
        return {
            'model_name': self.metadata.get('model_name'),
            'fingerprint_type': self.metadata.get('fingerprint'),
            'date_trained': self.metadata.get('date_trained'),
            'bioactivity_classes': self.metadata.get('bioactivity_classes'),
            'metrics': self.metadata.get('metrics'),
            'num_classes': len(self.label_encoder.classes_)
        }


# Global instance (lazy loaded)
_predictor = None

def get_predictor():
    """Get or initialize the global predictor instance"""
    global _predictor
    if _predictor is None:
        _predictor = SVMBioactivityPredictor()
    return _predictor


if __name__ == '__main__':
    # Test the predictor
    print("Testing SVM Bioactivity Predictor...\n")
    
    predictor = get_predictor()
    
    # Test cases
    test_smiles = [
        'CC(=O)Oc1ccccc1C(=O)O',  # Aspirin
        'CN1C=NC2=C1C(=O)N(C(=O)N2C)C',  # Caffeine
        'O=C(\\C=C/c1cc(O)c(O)c(O)c1)\\C=C/C(=O)c2c(O)cc(O)cc2O',  # Curcumin
    ]
    
    print(f"Model Info:")
    print(f"  Bioactivity Classes: {predictor.get_bioactivity_classes()}")
    print(f"  Accuracy: {predictor.get_model_info()['metrics']['test_accuracy']:.2%}\n")
    
    for smiles in test_smiles:
        result = predictor.predict(smiles)
        if result['success']:
            print(f"SMILES: {smiles}")
            print(f"  → {result['primary_bioactivity']} (confidence: {result['confidence']:.4f})")
        else:
            print(f"SMILES: {smiles}")
            print(f"  → Error: {result['error']}")
        print()
