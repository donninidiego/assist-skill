"""Block template: a factor that favours a preferred altitude.

Reference for the docstring layout of /assist Python projects: replace the physics, keep the sections.
"""

from __future__ import annotations

import numpy as np

from parameters import ExampleParams


def example_block(
    z_levels_m: np.ndarray, ref_altitude_m: float, example: ExampleParams
) -> np.ndarray:
    """Factor equal to ``gain`` at the preferred altitude, decreasing to 1 at ``width_m``.

    Physical Context:
        Say what the quantity means physically and why the block exists. Here: the vehicle flies
        preferably at one altitude; where the factor exceeds 1, flying costs less.

            t = (z - h_ref) / width_m           z: altitude [m]
            k = 1 + (gain - 1) * max(0, 1 - t**2)

    Theory:
        THEORY.md sec. F, Eq. (7'); [Author, Year, Eq. 3.2]. With ``gain = 0`` the condition K > 0
        would fail, hence the check below.

    Args:
        z_levels_m: altitude of each level [m], 1-D array.
        ref_altitude_m: preferred altitude [m].
        example: block parameters (``gain`` [-] > 0, ``width_m`` [m] > 0).

    Returns:
        Factor [-], one value per level.

    Assumptions:
        1. Absolute altitude, not height above ground.
        2. The factor depends only on altitude.

    Raises:
        ValueError: if ``gain`` or ``width_m`` is not positive.

    Example:
        >>> from parameters import default
        >>> par = default()
        >>> z = np.arange(0.0, 301.0, 5.0)
        >>> k = example_block(z, par.domain.ref_altitude_m, par.example)
        >>> float(k.max())
        2.0
    """
    if example.gain <= 0:
        raise ValueError("example_block: gain must be positive: with 0 the condition K > 0 would fail.")
    if example.width_m <= 0:
        raise ValueError("example_block: width_m must be positive.")

    t = (np.asarray(z_levels_m, dtype=float) - ref_altitude_m) / example.width_m  # [-] per level
    return 1.0 + (example.gain - 1.0) * np.maximum(0.0, 1.0 - t**2)
