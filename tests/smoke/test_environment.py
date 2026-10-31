"""
Test the environment setup for the forecast reliability testing.
The container should have the correct Python version, dependencies installed.
The Torch works on CPU only.
"""

import importlib
import sys
from importlib.metadata import version

import pytest

CORE_PACKAGES = [
    ("numpy", "numpy"),
    ("pandas", "pandas"),
    ("pyarrow", "pyarrow"),
    ("torch", "torch"),
    ("fastapi", "fastapi"),
    ("uvicorn", "uvicorn"),
    ("httpx", "httpx"),
    ("pydantic", "pydantic"),
    ("langgraph", "langgraph"),
    ("litellm", "litellm"),
    ("pytest", "pytest"),
    ("hypothesis", "hypothesis")
]

def test_python_version_is_pinned():
    assert sys.version_info[:2] == (3, 12), "Python version should be 3.12"

@pytest.mark.parametrize("package_name, import_name", CORE_PACKAGES, ids=[d for _, d in CORE_PACKAGES])
def test_package_imports(package_name, import_name):
    importlib.import_module(package_name)
    print(f"{import_name}=={version(import_name)}", end=" ")

def test_torch_is_cpu_only():
    import torch
    assert torch.version.cuda is None, "Torch should be CPU only, but CUDA is available"
    assert torch.__version__.endswith("+cpu"), "Torch should be CPU only, but the version does not indicate CPU support"

def test_lstm_forward_is_deterministic_with_fixed_seed():
    import torch

    def forward_once():
        torch.manual_seed(42)
        lstm = torch.nn.LSTM(input_size=1, hidden_size=8, batch_first=True)
        windows = torch.randn(4, 30, 1)  # batch_size=4, seq_len=30, input_size=1 == 4 windows x 30 sessions x 1 feature (e.g. close price)
        output, _ = lstm(windows)
        return output

    first, second = forward_once(), forward_once()
    assert first.shape == (4, 30, 8), "Output shape should be (batch_size, seq_len, hidden_size)"
    assert torch.equal(first, second), "LSTM forward pass should be deterministic with a fixed seed"