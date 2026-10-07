"""All parameters of the project, in one place.

Values only, each with its unit and a short label. Meaning, consumer and constraints of every field live
in docs (PARAMETERS.md).

Functions of the model receive ONE dataclass of ``Parameters`` (for example
``example_block(grid, par.example)``) and have no internal defaults: to change a parameter, change it here
or build a modified copy with ``dataclasses.replace`` before the call.

Usage:
    from parameters import default
    par = default()
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(frozen=True)
class DomainParams:
    max_altitude_m: float = 300.0  # [m] top of the computational domain
    dz_m: float = 5.0  # [m] vertical step
    ref_altitude_m: float = 150.0  # [m] preferred altitude


@dataclass(frozen=True)
class ExampleParams:
    gain: float = 2.0  # [-] factor at the preferred altitude (> 0; > 1 favours it)
    width_m: float = 50.0  # [m] half-width of the preferred layer (> 0)


@dataclass(frozen=True)
class Parameters:
    domain: DomainParams = field(default_factory=DomainParams)
    example: ExampleParams = field(default_factory=ExampleParams)


def default() -> Parameters:
    """Return a fresh set of parameters (the starting point of every run and every test)."""
    return Parameters()
