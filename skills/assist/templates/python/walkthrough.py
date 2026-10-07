# %% [markdown]
# # Project walkthrough: step by step
#
# This demo runs the chain of blocks **one step at a time**. Every step adds one element to the model and
# has the same four parts:
#
# 1. the **geometry or inputs**: what is fed into the block, before any effect is shown;
# 2. the **run**: the block is called with its dataclass of `par`;
# 3. the **result**: the field in 3D and 2D when it is spatial, with a printed numeric check;
# 4. the **entry into the next block**: how this output is used downstream.
#
# **Run time:** state here how long the demo takes and which parameters give a quick pass.

# %% [markdown]
# ## The idea on one page
# Describe the physical picture first, in researcher language, with every acronym expanded. Equations in
# Markdown math: $k(z) = 1 + (g - 1)\max(0,\, 1 - t^2), \quad t = (z - h_{ref}) / w$.

# %% Setup
import time
from pathlib import Path
import sys

import matplotlib.pyplot as plt
import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))  # project root: parameters.py, src
from example_block import example_block  # noqa: E402
from parameters import default  # noqa: E402

t_start = time.perf_counter()
par = default()  # a fresh set of parameters at every run
steps = []  # one entry per step, for the final comparison

# %% [markdown]
# ## Step 1: the domain
# **Inputs first.** The altitude levels the block will see, before any factor is computed.

# %%
z_levels_m = np.arange(0.0, par.domain.max_altitude_m + par.domain.dz_m, par.domain.dz_m)  # [m]
print(f"[Step1] levels: {z_levels_m.size}, from {z_levels_m[0]:g} m to {z_levels_m[-1]:g} m")
plt.plot(z_levels_m, np.zeros_like(z_levels_m), "k.")
plt.xlabel("Altitude [m]")
plt.title("Levels of the domain")
plt.show()

# %% [markdown]
# **What to observe:** evenly spaced levels covering the domain, one point per level.

# %% [markdown]
# ## Step 2: the example block
# **Idea.** The vehicle prefers one altitude. Where the factor $k$ is above 1, flying costs less, so the
# paths gather in that layer.

# %%
k = example_block(z_levels_m, par.domain.ref_altitude_m, par.example)
steps.append(("example block", float(k.min()), float(k.max()), z_levels_m.size))
plt.plot(z_levels_m, k, "k-", linewidth=1.5)
plt.xlabel("Altitude [m]")
plt.ylabel(r"$k$ [-]")
plt.title("Factor versus altitude")
plt.show()

# %% [markdown]
# **What to observe:** a parabola peaking at the preferred altitude and flat at 1 beyond the layer width.

# %% [markdown]
# ## Numeric check

# %%
i_ref = int(np.argmin(np.abs(z_levels_m - par.domain.ref_altitude_m)))
print(f"[Check] factor at preferred altitude: {k[i_ref]:.3f} (expected {par.example.gain:.3f})")
assert abs(k[i_ref] - par.example.gain) < 1e-12, "The factor at the preferred altitude must equal gain."

# %% [markdown]
# ## Result and comparison
# One row per step: what each element changed.

# %%
for name, k_min, k_max, n_lev in steps:
    print(f"{name:<18s} k in [{k_min:.2f}, {k_max:.2f}] over {n_lev} levels")
print(f"Total time: {time.perf_counter() - t_start:.1f} s")

# %% [markdown]
# ## Key points
# - Five lines the reader should keep after the demo.
# - Each states a fact that was shown above, not a claim that was not measured.
