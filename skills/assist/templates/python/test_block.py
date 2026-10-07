"""Verify the example block against analytic values (test template).

One test module per block. The header says what the block must guarantee and where the expected values
come from. Here: the factor is exactly ``gain`` at the preferred altitude, exactly 1 beyond the layer
width, and positive everywhere, which is the hypothesis the theory needs.

Run:  pytest tests/test_block.py
"""

from dataclasses import replace

import numpy as np
import pytest

from example_block import example_block
from parameters import default


@pytest.fixture
def par():
    return default()


@pytest.fixture
def z_levels(par):
    d = par.domain
    return np.arange(0.0, d.max_altitude_m + d.dz_m, d.dz_m)


def test_factor_equals_gain_at_preferred_altitude(par, z_levels):
    k = example_block(z_levels, par.domain.ref_altitude_m, par.example)
    i = np.argmin(np.abs(z_levels - par.domain.ref_altitude_m))
    assert k[i] == pytest.approx(par.example.gain, abs=1e-12)


def test_factor_is_one_beyond_the_layer_width(par, z_levels):
    k = example_block(z_levels, par.domain.ref_altitude_m, par.example)
    far = np.abs(z_levels - par.domain.ref_altitude_m) >= par.example.width_m
    assert np.allclose(k[far], 1.0, atol=1e-12)


def test_factor_is_strictly_positive(par, z_levels):
    ex = replace(par.example, gain=0.01)  # strongly penalizing layer
    k = example_block(z_levels, par.domain.ref_altitude_m, ex)
    assert np.all(k > 0)


def test_non_positive_gain_is_rejected(par, z_levels):
    ex = replace(par.example, gain=0.0)
    with pytest.raises(ValueError, match="gain must be positive"):
        example_block(z_levels, par.domain.ref_altitude_m, ex)
