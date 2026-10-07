# Parameters

Values live in `parameters.m`; this file explains them. One table per sub-struct of `par`.

## `par.domain` — received by block 1
| Field | Default | Meaning | Consumer |
|---|---|---|---|
| `dz_m` | 5 | [m] vertical step | `<function>` |
| `max_altitude_m` | 300 | [m] top of the domain; constraint: > `ref_altitude_m` | `<function>` |

## `par.<block>` — received by block N
| Field | Default | Meaning | Consumer |
|---|---|---|---|

## Scenario lists
`par.scenario.<list>` starts empty (typed struct) and is filled by scripts; format of one entry: ...
