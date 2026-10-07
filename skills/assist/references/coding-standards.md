# Coding Standards Guide
## Python & MATLAB

---

## Table of Contents
1. [General Principles](#general-principles)
2. [Python Standards](#python-standards)
3. [MATLAB Standards](#matlab-standards)
4. [Version Control](#version-control)
5. [Documentation](#documentation)
6. [Scientific Documentation & References](#scientific-documentation--references)
7. [Testing](#testing)

---

## General Principles

### Code Readability
- **Write code for humans first, computers second** - Your future self will thank you
- **Use meaningful names** - Variable and function names should explain their purpose AND physical context
- **Keep it simple** - Prefer clarity over cleverness
- **Be consistent** - Pick a style and stick with it

### Scientific Code Principles
- **Traceability** - Every equation must be traceable to its source (paper, textbook, DOI)
- **Physical clarity** - Always specify reference frames, units, and physical interpretation
- **Documentation** - Theory comes first, implementation second
- **Reproducibility** - Others (including future you) should be able to verify your results

### Project Organization
```
project/
├── src/              # Source code
├── tests/            # Test files
├── docs/             # Documentation
├── data/             # Data files (if applicable)
├── notebooks/        # Jupyter/MATLAB Live Scripts
├── README.md         # Project overview
├── REFERENCES.md     # **MANDATORY for scientific code - theoretical sources**
└── requirements.txt  # Python dependencies (or environment.yml)
```

---

## Python Standards

### Style Guide
Follow **PEP 8** as the foundation. Key highlights:

#### Naming Conventions
```python
# Variables and functions: lowercase with underscores
user_count = 42
def calculate_average(values):
    pass

# Constants: UPPERCASE with underscores
MAX_ITERATIONS = 1000
PI_APPROXIMATION = 3.14159

# Classes: PascalCase
class DataProcessor:
    pass

# Private methods/variables: leading underscore
def _internal_helper():
    pass
```

#### Indentation and Line Length
- Use **4 spaces** per indentation level (not tabs)
- Keep lines under **79 characters** for code, **72 for comments**
- Break long lines logically:

```python
# Good
result = some_function(
    argument_one,
    argument_two,
    argument_three
)

# Also good for function definitions
def long_function_name(
    parameter_one: int,
    parameter_two: str,
    parameter_three: float
) -> dict:
    pass
```

#### Imports
```python
# Standard library first
import os
import sys
from pathlib import Path

# Third-party packages
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Local application imports
from my_module import my_function
```

#### String Formatting
Prefer **f-strings** (Python 3.6+):
```python
name = "Alice"
age = 30

# Good
message = f"Hello, {name}! You are {age} years old."

# Avoid
message = "Hello, " + name + "! You are " + str(age) + " years old."
```

#### Type Hints
Use type hints for better code clarity:
```python
def process_data(
    input_file: str,
    threshold: float = 0.5
) -> list[dict]:
    """Process data from input file.
    
    Args:
        input_file: Path to input data file
        threshold: Filtering threshold (default: 0.5)
        
    Returns:
        List of processed data dictionaries
    """
    results = []
    # ... processing logic
    return results
```

#### Error Handling
```python
# Be specific with exceptions
try:
    data = load_file(filename)
except FileNotFoundError:
    print(f"File {filename} not found")
    return None
except PermissionError:
    print(f"Permission denied for {filename}")
    return None

# Avoid bare except:
# except:  # Don't do this
```

#### List Comprehensions vs Loops
Use comprehensions for simple transformations:
```python
# Good for simple operations
squares = [x**2 for x in range(10)]
filtered = [x for x in values if x > 0]

# Use regular loops for complex logic
results = []
for item in data:
    if item.needs_processing():
        processed = item.complex_transformation()
        if processed.is_valid():
            results.append(processed)
```

### Documentation

#### Docstrings
Use **Google or NumPy style** docstrings:
```python
def calculate_statistics(data, method="mean"):
    """Calculate statistical measures for the given data.
    
    Args:
        data (array-like): Input data array
        method (str): Statistical method to use. Options: 'mean', 'median', 'mode'
            Default is 'mean'.
    
    Returns:
        float: The calculated statistic
        
    Raises:
        ValueError: If method is not recognized
        
    Example:
        >>> data = [1, 2, 3, 4, 5]
        >>> calculate_statistics(data, method='mean')
        3.0
    """
    if method == "mean":
        return sum(data) / len(data)
    elif method == "median":
        return np.median(data)
    else:
        raise ValueError(f"Unknown method: {method}")
```

### Best Practices

#### Use Context Managers
```python
# Good - automatic cleanup
with open('data.txt', 'r') as f:
    content = f.read()

# Avoid
f = open('data.txt', 'r')
content = f.read()
f.close()  # Easy to forget
```

#### Avoid Magic Numbers
```python
# Bad
if speed > 100:
    alert()

# Good
SPEED_LIMIT = 100
if speed > SPEED_LIMIT:
    alert()
```

#### Use enumerate() and zip()
```python
# Good
for i, value in enumerate(items):
    print(f"Item {i}: {value}")

for name, score in zip(names, scores):
    print(f"{name}: {score}")

# Avoid
for i in range(len(items)):
    print(f"Item {i}: {items[i]}")
```

---

## MATLAB Standards

### Style Guide

#### Naming Conventions
```matlab
% Variables and functions: camelCase
userCount = 42;
function result = calculateAverage(values)
    % Function body
end

% Constants: UPPERCASE with underscores
MAX_ITERATIONS = 1000;
PI_APPROXIMATION = 3.14159;

% Classes: PascalCase
classdef DataProcessor
    % Class body
end
```

#### File Organization
- **One function per file** (except local functions)
- **File name matches main function name**
- Use **lowercase** for script files: `data_analysis.m`
- Use **camelCase** for function files: `calculateStatistics.m`

#### Indentation and Formatting
```matlab
% Use 4 spaces for indentation
function result = processData(input, options)
    % Process data with given options
    
    if nargin < 2
        options = struct('method', 'default');
    end
    
    % Initialize
    result = zeros(size(input));
    
    % Process each element
    for i = 1:length(input)
        result(i) = transform(input(i), options);
    end
end
```

#### Vectorization
Prefer vectorized operations over loops:
```matlab
% Good - vectorized
x = 1:1000;
y = sin(x) .* exp(-x/100);

% Avoid - loop when vectorization possible
y = zeros(size(x));
for i = 1:length(x)
    y(i) = sin(x(i)) * exp(-x(i)/100);
end

% But loops are fine when logic is complex
```

#### Preallocate Arrays
```matlab
% Good
n = 1000;
result = zeros(n, 1);
for i = 1:n
    result(i) = computeValue(i);
end

% Avoid - growing arrays
result = [];
for i = 1:n
    result = [result; computeValue(i)];  % Slow!
end
```

### Documentation

#### Function Headers
```matlab
function [output1, output2] = myFunction(input1, input2, varargin)
% MYFUNCTION One-line description of what the function does
%
%   OUTPUT1 = MYFUNCTION(INPUT1, INPUT2) does something specific.
%   Provide more detailed description here.
%
%   [OUTPUT1, OUTPUT2] = MYFUNCTION(INPUT1, INPUT2, 'Name', Value)
%   specifies optional parameters using name-value pairs.
%
%   Inputs:
%       input1 - Description of first input (double array)
%       input2 - Description of second input (string)
%       Optional name-value pairs:
%           'Method'   - Algorithm to use (default: 'auto')
%           'Verbose'  - Display progress (default: false)
%
%   Outputs:
%       output1 - Description of first output (double array)
%       output2 - Description of second output (struct)
%
%   Example:
%       data = rand(100, 1);
%       [result, info] = myFunction(data, 'method1', 'Verbose', true);
%
%   See also: RELATEDFUNCTION1, RELATEDFUNCTION2

% Input validation
arguments
    input1 double
    input2 string
end

% Function body
% ...

end
```

#### Comments
```matlab
% Use comments to explain WHY, not WHAT
% Bad: Add 1 to x
x = x + 1;

% Good: Adjust for 1-based indexing
x = x + 1;

% Section breaks for longer files
%% Data Loading and Preprocessing

%% Feature Extraction

%% Model Training
```

### Best Practices

#### Input Validation
```matlab
function result = myFunction(data, options)
    % Use arguments block (R2019b+)
    arguments
        data double {mustBeNumeric, mustBeReal}
        options.Method string = "default"
        options.Threshold double = 0.5
    end
    
    % Or use validateattributes
    validateattributes(data, {'numeric'}, {'real', 'vector'});
    
    % Process data
    result = process(data, options);
end
```

#### Error Handling
```matlab
% Use try-catch for error handling
try
    data = load(filename);
catch ME
    if strcmp(ME.identifier, 'MATLAB:load:couldNotReadFile')
        warning('Could not load file: %s', filename);
        data = [];
    else
        rethrow(ME);
    end
end

% Use assert for preconditions
assert(all(data >= 0), 'Data must be non-negative');
```

#### Avoid Global Variables
```matlab
% Bad
global CONFIG;
CONFIG.threshold = 0.5;

% Good - use function arguments or nested functions
function main()
    config = struct('threshold', 0.5);
    result = processData(data, config);
end
```

#### Use Structures for Parameters
```matlab
% Good - easy to extend
params = struct(...
    'learningRate', 0.01, ...
    'maxIterations', 1000, ...
    'tolerance', 1e-6 ...
);
result = trainModel(data, params);

% Avoid - hard to maintain
result = trainModel(data, 0.01, 1000, 1e-6);
```

### Plotting and Visualization (Academic Quality)

All MATLAB plots intended for reports, papers, or documentation **MUST** follow strict academic and typography standards to ensure publication readiness:

#### 0. Ask Before Adapting Plots to a Journal
**Before writing any plotting code, an AI assistant working in this codebase MUST ask the user:**
1. Is this plot intended for a specific journal/paper submission?
2. If yes, does it need to be adapted to that journal's format — column width, font size matching the body text, one figure per plot so multiple plots can be composed as subfigures directly in the LaTeX source?

- **If the user confirms a journal target**: gather the relevant details (journal/template, e.g. `elsarticle`, single/double column width, target font size in pt) and apply an explicit physical figure size (`Units='centimeters'`, `Position`/`PaperSize` matching the journal's column width) with a matching absolute `FontSize`. Default to **one figure per plot** — do not combine unrelated plots into MATLAB `subplot`s for a paper; let LaTeX compose them as subfigures instead. The one exception is metrics the user explicitly identifies as a conceptual pair (e.g. 2D/3D distance, pitch/roll) — those may be combined as a real 2-subplot MATLAB figure sized to the double-column width, since they are meant to be read together as a single result, not composed independently in LaTeX.
- **If the user does not specify a journal, or explicitly declines this adaptation**: default to point 5 below (MATLAB default figure sizing, no custom `Position`/`FontSize`).

This question must be asked every time plotting is requested, not just once per project — different plots in the same session may target different outlets (e.g., a quick diagnostic figure vs. a paper-ready one).

#### 1. Text Interpreter and Font
**Default (no journal target, see point 0 above)**: always use the LaTeX interpreter for text objects to seamlessly match the thesis/paper typography (Computer Modern). Do not mix default fonts with LaTeX.
```matlab
% 1. Text, Titles, and Axis Labels
title('Topography Analysis', 'Interpreter', 'latex');
xlabel('Longitude [$^\circ$]', 'Interpreter', 'latex');

% 2. Axis Ticks (Numbers) and Colorbar
ax = gca;
ax.TickLabelInterpreter = 'latex';
c = colorbar;
c.TickLabelInterpreter = 'latex';
c.Label.Interpreter = 'latex';
```

**When adapting to a specific Elsevier journal (point 0 confirmed)**: use `Interpreter,'tex'` with `FontName,'Times New Roman'` instead, **not** `'latex'`. Elsevier's artwork instructions list the recommended typefaces for lettering in figures as **Arial/Helvetica, Courier, Times/Times New Roman, Symbol** — Computer Modern (what MATLAB's `'latex'` interpreter embeds) is not on that list, and Elsevier explicitly warns that non-standard fonts may be substituted or cause missing/overlapping glyphs in their production pipeline. This was verified empirically: a PDF exported with `Interpreter,'latex'` embeds the font as `mwa_cmr10` (a Computer Modern subset), confirmed by inspecting the PDF's embedded font table.

```matlab
% 'tex' interpreter drops the $...$ math-mode delimiters LaTeX needs,
% but still supports subscript/superscript via bare _ and ^:
title('Path Ratio 2D (L_{2D}/D)', 'Interpreter', 'tex');
xlabel('Longitude [\circ]', 'Interpreter', 'tex');

ax = gca;
ax.TickLabelInterpreter = 'tex';

% Font must be set explicitly -- 'tex' does not default to Times New Roman:
set(findall(fig, 'Type', 'axes'),  'FontName', 'Times New Roman', 'FontSize', 7);
set(findall(fig, 'Type', 'text'),  'FontName', 'Times New Roman', 'FontSize', 7);
set(findall(fig, 'Type', 'legend'),'FontName', 'Times New Roman', 'FontSize', 7);
```
Note the `'tex'` interpreter only supports a subset of LaTeX math syntax (subscripts, superscripts, Greek letters, a handful of symbols) — no `\frac`, no `$...$` delimiters, no custom packages. For the plots in this codebase (axis labels, simple ratios, Greek letters) this subset is sufficient; verify complex equations render correctly before relying on it.

#### 2. Sober Aesthetics & High Contrast
- Avoid the default "rainbow" marker color configurations (e.g., mixing `r`, `g`, `b`, `c`, `m` arbitrarily).
- Use uniform, high-contrast styles. For instance, when overlaying markers on maps/images: use empty shapes (`MarkerFaceColor, 'none'`) with high-contrast borders (black or white, depending on the background) and thick lines (`LineWidth, 1.5`).
- **Overlays & Constraints**: When highlighting regions (e.g., hard constraints or invalid zones) over grayscale maps (`gray` colormap), use a dark transparent red overlay.
  ```matlab
  redMask = zeros([size(Z), 3]);
  redMask(:,:,1) = 1; % Red channel
  hMask = imagesc(X, Y, redMask);
  set(hMask, 'AlphaData', double(ConstraintMask) * 0.4); % 40% transparency
  ```

#### 3. Clarity over Complexity
- **Contours vs Images**: Do not automatically clutter plots. Sealing a densely populated `imagesc` or `surf` representation with a huge number of `contour` lines often destroys readability.
- If using contours, minimize the isoline count and always use `clabel` with generous label spacing to avoid unreadable numerical overlaps.

#### 4. Physical Units
- Always specify physical units securely enclosed by square brackets formatted via LaTeX notation (e.g., `Elevation [m]` instead of `(m)`).

#### 5. Figure Sizing and Export Coherence
- **Default (no journal target, see point 0 above)**: never hardcode the `Position` property when creating a `figure` (e.g., avoid `figure('Position', [100, 100, 1600, 800])`). Let MATLAB use its default figure sizing (e.g., `f = figure('Name', 'My Plot', 'Color', 'w')`). This ensures that when plots are exported via `exportgraphics`, they all share the identical baseline physical dimension, so when imported and scaled into a LaTeX document, the typographic scaling stays uniform across all figures in the paper. Never artificially inflate `FontSize` (e.g., to 18pt or 22pt) to compensate for massive pixel-resolution windows — keep to the standard 10pt-12pt and let the LaTeX document handle the physical rendering.
- **When adapting to a specific journal (point 0 confirmed)**: for Elsevier journals (including `elsarticle`-based ones like Aerospace Science and Technology), use the publisher's own official artwork sizing spec rather than guessing — see [Elsevier Artwork Sizing](https://www.elsevier.com/about/policies-and-standards/author/artwork-and-media-instructions/artwork-sizing):

  | Format | Width | Use for |
  |---|---|---|
  | Minimal | 30 mm | small inset figures |
  | Single column | **90 mm** | one plot per figure |
  | 1.5 column | 140 mm | rarely used |
  | Double column (full page) | **190 mm** | 2-subplot figures, or a figure meant to span the page |

  Lettering finished print size: **7 pt for normal text**, no smaller than **6 pt** for sub/superscripts; up to **10 pt** is acceptable for figures with complex visual elements. Set the figure's physical size explicitly (`Units='centimeters'`, `Position`/`PaperSize` matching the table above) and apply this font size uniformly to every axis/label/legend in the figure — don't rely on a LaTeX-side scale factor to get there, since the artwork is meant to already be at (or proportional to) its final print size before export. See point 1 above for the font family to pair with this size (Times New Roman via `Interpreter,'tex'`, not Computer Modern via `'latex'`).
  - Resolution only matters for raster exports (vector PDF/EPS is resolution-independent): 300 dpi for halftone/photographic images, 500 dpi for combination art, 1000 dpi for pure line art.
  - These numbers are Elsevier's general policy, applied across their journals; always check the specific journal's own Guide for Authors for any additional or overriding requirements.

---

## Version Control

### Git Basics
```bash
# Initialize repository
git init

# Create .gitignore
echo "*.pyc" >> .gitignore
echo "__pycache__/" >> .gitignore
echo "*.m~" >> .gitignore  # MATLAB backup files
echo ".DS_Store" >> .gitignore
echo "*.asv" >> .gitignore  # MATLAB autosave
```

### Commit Messages
Use clear, descriptive commit messages:
```
Good commit messages:
- "Add data validation to process_data function"
- "Fix bug in matrix multiplication for edge cases"
- "Refactor plotting code for better readability"

Avoid:
- "fix stuff"
- "update"
- "changes"
```

### Branching Strategy (Optional for Solo)
```bash
# main branch for stable code
# feature branches for new work
git checkout -b feature/new-analysis
# ... make changes ...
git checkout main
git merge feature/new-analysis
```

---

## Documentation

### README.md Template
```markdown
# Project Name

Brief description of what this project does.

## Requirements
- Python 3.9+
- MATLAB R2021a+
- Required packages listed in requirements.txt

## Installation
```bash
pip install -r requirements.txt
```

## Usage
```python
from my_module import analyze_data
results = analyze_data('data.csv')
```

## Project Structure
- `src/` - Source code
- `tests/` - Unit tests
- `data/` - Sample data
- `notebooks/` - Analysis notebooks

## Author
Your Name
```

### Inline Comments
```python
# Good comments explain WHY
# We use a threshold of 0.5 because values below this are considered noise
threshold = 0.5

# Bad comments state the obvious
# Set threshold to 0.5
threshold = 0.5
```

---

## Scientific Documentation & References

### REFERENCES.md - Theoretical Sources File

**MANDATORY**: Every project implementing physical models or algorithms from literature MUST include a `REFERENCES.md` file in the root directory.

#### Template for REFERENCES.md

```markdown
# Theoretical References

## Overview
Brief description of the physical problem or model being implemented.

---

## Primary Sources

### [Reference 1 - Main Model]
**Title**: Full paper title  
**Authors**: Author names  
**Journal/Conference**: Publication venue, Year  
**DOI/Link**: https://doi.org/10.xxxx/xxxxx or [ArXiv](https://arxiv.org/abs/xxxx.xxxxx)

**Relevance**: Describe which part of your code implements this (e.g., "Main equations for coordinate transformation, implemented in `transform_coordinates.py`")

**Key Equations Implemented**:
- Equation 3.2 (page 5): Transformation matrix - `calculateRotationMatrix()`
- Equation 4.1 (page 8): Velocity vector - `computeVelocity()`

**Notes**: Any assumptions, simplifications, or modifications you made to the original formulation.

---

### [Reference 2 - Validation Data]
**Title**: ...  
**DOI/Link**: ...  
**Relevance**: Used for validation of results in `tests/validation_test.py`

---

## Secondary Sources

### Textbooks
- Author, "Book Title", Chapter X, Pages Y-Z - Used for background theory
- [Online resource](URL) - Description of what was used

### Software Documentation
- Library name and version - Specific algorithms or implementations used

---

## Implementation Notes

### Coordinate Systems Used
- **Input coordinates**: Earth-fixed frame (ECI/ECEF/NED - specify which)
- **Output coordinates**: Body frame / Inertial frame (specify)
- **Transformations**: List all coordinate transformations and their references

### Physical Assumptions
1. Assumption 1 (e.g., "Small angle approximation valid for θ < 10°") - Source: [Ref 1], Eq. 2.3
2. Assumption 2 (e.g., "Atmospheric density follows exponential model") - Source: [Ref 3]

---

## Notation Correspondence

| Paper Notation | Code Variable | Description |
|----------------|---------------|-------------|
| θ (theta) | `angle_horizon` | Angle from horizon [rad] |
| **v** | `velocity_ecef` | Velocity vector in ECEF frame [m/s] |
| Ω (omega) | `angular_rate` | Angular rate [rad/s] |
| ρ (rho) | `air_density` | Atmospheric density [kg/m³] |

---

## Version History
- v1.0 (2024-01-15): Initial implementation based on [Ref 1]
- v1.1 (2024-02-20): Added validation against [Ref 2] data
```

---

### Function Documentation with Physical Context

Every function implementing a physical model MUST document:
1. **Physical meaning** of inputs and outputs
2. **Reference frame** for vectors
3. **Units** for all quantities
4. **Source equation** from literature
5. **Assumptions** and validity range

#### Python Example

```python
def transform_velocity_ecef_to_body(
    velocity_ecef: np.ndarray,
    euler_angles: np.ndarray,
    reference_point: np.ndarray
) -> np.ndarray:
    """Transform velocity vector from ECEF to body-fixed reference frame.
    
    Physical Context:
        Implements the coordinate transformation from Earth-Centered Earth-Fixed
        (ECEF) inertial frame to aircraft body-fixed frame using Euler angles.
        This is essential for relating ground-based measurements to aircraft
        motion in aerodynamic analyses.
    
    Theory:
        Based on Stevens & Lewis "Aircraft Control and Simulation", 3rd Ed.
        Equation 1.3-8 (page 15) and Equation 1.4-3 (page 22)
        DOI: 10.1002/9781119174882
        
        The transformation uses the 3-2-1 (yaw-pitch-roll) Euler sequence,
        which is standard in aerospace applications.
    
    Args:
        velocity_ecef: Velocity vector in ECEF frame [m/s]
            - 3D numpy array [vx, vy, vz]
            - ECEF frame: X-axis through 0°N 0°E, Z-axis through North Pole
            - Origin at Earth's center
            
        euler_angles: Euler angles [rad] as [yaw, pitch, roll]
            - Yaw (ψ): rotation about Z-axis (0° = North)
            - Pitch (θ): rotation about Y-axis (positive = nose up)
            - Roll (φ): rotation about X-axis (positive = right wing down)
            - Range: yaw [0, 2π], pitch [-π/2, π/2], roll [-π, π]
            
        reference_point: Position of body frame origin in ECEF [m]
            - 3D numpy array [x, y, z]
            - Used for velocity composition if body frame is moving
    
    Returns:
        velocity_body: Velocity vector in body-fixed frame [m/s]
            - 3D numpy array [u, v, w]
            - Body frame: X-forward, Y-right, Z-down (NED convention)
            - u: axial velocity (along longitudinal axis)
            - v: lateral velocity (along lateral axis)  
            - w: normal velocity (along vertical axis, positive down)
    
    Assumptions:
        1. Rigid body assumption (no structural deformation)
        2. ECEF frame approximated as inertial (valid for short durations)
        3. Euler angles within standard range (no gimbal lock)
    
    Raises:
        ValueError: If euler_angles pitch is outside [-π/2, π/2]
        
    Example:
        >>> # Aircraft flying north at 100 m/s, level flight
        >>> v_ecef = np.array([0, 100, 0])  # North in ECEF
        >>> angles = np.array([0, 0, 0])    # Level, heading north
        >>> pos = np.array([0, 0, 0])       # At origin
        >>> v_body = transform_velocity_ecef_to_body(v_ecef, angles, pos)
        >>> print(v_body)  # Expected: [100, 0, 0] (forward velocity)
        
    See Also:
        - transform_body_to_ecef(): Inverse transformation
        - calculate_rotation_matrix(): Low-level rotation matrix computation
        
    References:
        [1] Stevens, B.L., Lewis, F.L. (2003). "Aircraft Control and Simulation"
            Section 1.3: Coordinate Systems, Equation 1.3-8
            DOI: 10.1002/9781119174882
    """
    # Validate inputs
    if not -np.pi/2 <= euler_angles[1] <= np.pi/2:
        raise ValueError(f"Pitch angle {euler_angles[1]} rad outside valid range")
    
    # Extract Euler angles
    psi, theta, phi = euler_angles  # yaw, pitch, roll
    
    # Compute rotation matrix (DCM) from ECEF to body
    # Following Stevens & Lewis Eq. 1.3-8
    R_eb = _compute_dcm_ecef_to_body(psi, theta, phi)
    
    # Apply rotation
    velocity_body = R_eb @ velocity_ecef
    
    return velocity_body


def _compute_dcm_ecef_to_body(
    psi: float,
    theta: float, 
    phi: float
) -> np.ndarray:
    """Compute Direction Cosine Matrix for ECEF to body transformation.
    
    Theory:
        Implements 3-2-1 Euler angle sequence (yaw-pitch-roll).
        From Stevens & Lewis, Equation 1.4-3.
        
    Args:
        psi: Yaw angle [rad]
        theta: Pitch angle [rad]
        phi: Roll angle [rad]
        
    Returns:
        R_eb: 3x3 rotation matrix (Direction Cosine Matrix)
            Transforms vectors from ECEF to body frame: v_body = R_eb @ v_ecef
    """
    # Individual rotation matrices
    # R3(psi) - rotation about Z (yaw)
    R3 = np.array([
        [np.cos(psi), np.sin(psi), 0],
        [-np.sin(psi), np.cos(psi), 0],
        [0, 0, 1]
    ])
    
    # R2(theta) - rotation about Y (pitch)
    R2 = np.array([
        [np.cos(theta), 0, -np.sin(theta)],
        [0, 1, 0],
        [np.sin(theta), 0, np.cos(theta)]
    ])
    
    # R1(phi) - rotation about X (roll)
    R1 = np.array([
        [1, 0, 0],
        [0, np.cos(phi), np.sin(phi)],
        [0, -np.sin(phi), np.cos(phi)]
    ])
    
    # Combined rotation: R_eb = R1 * R2 * R3 (applied right to left)
    R_eb = R1 @ R2 @ R3
    
    return R_eb
```

#### MATLAB Example

```matlab
function velocityBody = transformVelocityEcefToBody(velocityEcef, eulerAngles, referencePoint)
% TRANSFORMVELOCITYECEFTOBODY Transform velocity from ECEF to body-fixed frame
%
%   PHYSICAL CONTEXT:
%   Implements coordinate transformation from Earth-Centered Earth-Fixed
%   (ECEF) inertial frame to aircraft body-fixed frame using Euler angles.
%   Essential for relating ground-based measurements to aircraft motion.
%
%   THEORY:
%   Based on Stevens & Lewis "Aircraft Control and Simulation", 3rd Ed.
%   Equation 1.3-8 (page 15) and Equation 1.4-3 (page 22)
%   DOI: 10.1002/9781119174882
%   
%   Uses 3-2-1 (yaw-pitch-roll) Euler sequence, standard in aerospace.
%
%   VELOCITYBODY = TRANSFORMVELOCITYECEFTOBODY(VELOCITYECEF, EULERANGLES, REFERENCEPOINT)
%
%   Inputs:
%       velocityEcef - Velocity vector in ECEF frame [m/s]
%           • 3x1 or 1x3 array [vx, vy, vz]
%           • ECEF frame: X-axis through 0°N 0°E, Z through North Pole
%           • Origin at Earth's center
%
%       eulerAngles - Euler angles [rad] as [yaw, pitch, roll]
%           • Yaw (ψ): rotation about Z-axis (0° = North)
%           • Pitch (θ): rotation about Y-axis (positive = nose up)  
%           • Roll (φ): rotation about X-axis (positive = right wing down)
%           • Range: yaw [0, 2π], pitch [-π/2, π/2], roll [-π, π]
%
%       referencePoint - Position of body frame origin in ECEF [m]
%           • 3x1 or 1x3 array [x, y, z]
%           • Used for velocity composition if body frame is moving
%
%   Outputs:
%       velocityBody - Velocity vector in body-fixed frame [m/s]
%           • 3x1 array [u, v, w]
%           • Body frame: X-forward, Y-right, Z-down (NED convention)
%           • u: axial velocity (along longitudinal axis)
%           • v: lateral velocity (along lateral axis)
%           • w: normal velocity (along vertical axis, positive down)
%
%   ASSUMPTIONS:
%   1. Rigid body (no structural deformation)
%   2. ECEF approximated as inertial (valid for short durations < 1 hour)
%   3. Euler angles within standard range (no gimbal lock at ±90° pitch)
%
%   Example:
%       % Aircraft flying north at 100 m/s, level flight
%       vEcef = [0; 100; 0];           % North in ECEF
%       angles = [0; 0; 0];            % Level, heading north  
%       pos = [0; 0; 0];               % At origin
%       vBody = transformVelocityEcefToBody(vEcef, angles, pos);
%       % Expected: [100; 0; 0] (forward velocity)
%
%   See also: TRANSFORMBODYTOECEF, COMPUTEROTATIONMATRIX
%
%   References:
%   [1] Stevens, B.L., Lewis, F.L. (2003). "Aircraft Control and Simulation"
%       Section 1.3: Coordinate Systems, Equation 1.3-8
%       DOI: 10.1002/9781119174882

    % Input validation
    arguments
        velocityEcef (3,1) double
        eulerAngles (3,1) double
        referencePoint (3,1) double
    end
    
    % Check pitch angle range (avoid gimbal lock)
    theta = eulerAngles(2);
    assert(abs(theta) < pi/2, ...
        'Pitch angle %.2f rad outside valid range [-π/2, π/2]', theta);
    
    % Extract Euler angles
    psi = eulerAngles(1);    % yaw
    theta = eulerAngles(2);  % pitch  
    phi = eulerAngles(3);    % roll
    
    % Compute Direction Cosine Matrix (DCM) from ECEF to body
    % Following Stevens & Lewis Eq. 1.3-8
    Reb = computeDcmEcefToBody(psi, theta, phi);
    
    % Apply rotation: v_body = R_eb * v_ecef
    velocityBody = Reb * velocityEcef;
    
end

function Reb = computeDcmEcefToBody(psi, theta, phi)
% COMPUTEDCMECEFTOBODY Compute Direction Cosine Matrix for transformation
%
%   THEORY:
%   Implements 3-2-1 Euler angle sequence (yaw-pitch-roll).
%   From Stevens & Lewis, Equation 1.4-3.
%
%   Inputs:
%       psi   - Yaw angle [rad]
%       theta - Pitch angle [rad]
%       phi   - Roll angle [rad]
%
%   Outputs:
%       Reb - 3x3 Direction Cosine Matrix
%           Transforms vectors: v_body = Reb * v_ecef

    % Individual rotation matrices
    
    % R3(psi) - Rotation about Z-axis (yaw)
    R3 = [cos(psi),  sin(psi), 0;
         -sin(psi),  cos(psi), 0;
          0,         0,        1];
    
    % R2(theta) - Rotation about Y-axis (pitch)
    R2 = [cos(theta), 0, -sin(theta);
          0,          1,  0;
          sin(theta), 0,  cos(theta)];
    
    % R1(phi) - Rotation about X-axis (roll)
    R1 = [1,  0,         0;
          0,  cos(phi),  sin(phi);
          0, -sin(phi),  cos(phi)];
    
    % Combined rotation: R_eb = R1 * R2 * R3 (applied right to left)
    Reb = R1 * R2 * R3;
    
end
```

---

### Variable Naming for Physical Quantities

Use descriptive names that include reference frame information:

#### Good Examples
```python
# Python
position_ecef          # Position in ECEF frame
velocity_body          # Velocity in body frame
angle_attack           # Angle of attack
force_aero_wind        # Aerodynamic force in wind frame
acceleration_eci       # Acceleration in ECI frame
quaternion_body_to_ned # Quaternion for body→NED transformation

# MATLAB
positionEcef
velocityBody  
angleAttack
forceAeroWind
accelerationEci
quaternionBodyToNed
```

#### Frame/System Abbreviations
- `ecef` - Earth-Centered Earth-Fixed
- `eci` - Earth-Centered Inertial
- `ned` - North-East-Down
- `body` - Body-fixed frame
- `wind` - Wind-axis frame
- `stability` - Stability-axis frame
- `perifocal` - Perifocal orbital frame

#### Unit Suffixes (when ambiguous)
```python
altitude_m          # meters
altitude_ft         # feet
angle_rad          # radians
angle_deg          # degrees
time_s             # seconds
mass_kg            # kilograms
temperature_k      # Kelvin
```

---

### Project Structure for Scientific Code

```
project/
├── README.md                    # Project overview
├── REFERENCES.md               # **MANDATORY** - All theoretical sources
├── requirements.txt            # Python dependencies
├── src/
│   ├── models/                 # Physical model implementations
│   │   ├── kinematics.py      # Each module documents its equations
│   │   ├── dynamics.py
│   │   └── aerodynamics.py
│   ├── coordinates/            # Coordinate transformations
│   │   └── transforms.py
│   └── utils/
│       └── constants.py        # Physical constants with sources
├── tests/
│   ├── unit/                   # Unit tests
│   ├── validation/             # Validation against literature
│   │   └── validation_data/    # Reference data from papers
│   └── integration/
├── docs/
│   ├── theory/                 # Detailed derivations (optional)
│   │   └── coordinate_systems.md
│   └── figures/                # Diagrams of reference frames
├── notebooks/
│   └── validation_plots.ipynb  # Compare with paper results
└── data/
    └── reference/              # Data from literature for validation
```

---

### Constants and Physical Parameters

Document source for all physical constants:

```python
# constants.py
"""Physical and mathematical constants used throughout the project.

All values sourced from authoritative references.
"""

import numpy as np

# ============================================================================
# Mathematical Constants
# ============================================================================
PI = np.pi

# ============================================================================
# Fundamental Physical Constants
# Source: CODATA 2018 (doi.org/10.1103/RevModPhys.93.025010)
# ============================================================================

SPEED_OF_LIGHT = 299792458.0  # [m/s] - exact by definition
"""Speed of light in vacuum.
Source: CODATA 2018, exact value by SI definition.
"""

GRAVITATIONAL_CONSTANT = 6.67430e-11  # [m³/(kg·s²)]
"""Newtonian constant of gravitation.
Source: CODATA 2018, doi.org/10.1103/RevModPhys.93.025010
Uncertainty: ±0.00015e-11 m³/(kg·s²)
"""

# ============================================================================
# Earth Parameters  
# Source: WGS84 (NIMA TR8350.2, 3rd Ed., 2000)
# ============================================================================

EARTH_RADIUS_EQUATORIAL = 6378137.0  # [m]
"""Earth equatorial radius (semi-major axis).
Source: WGS84 ellipsoid definition
Reference: NIMA TR8350.2, Department of Defense World Geodetic System 1984
"""

EARTH_FLATTENING = 1.0 / 298.257223563
"""Earth flattening factor.
Source: WGS84, f = (a-b)/a where a=equatorial, b=polar radius
"""

EARTH_ANGULAR_VELOCITY = 7.292115e-5  # [rad/s]
"""Earth rotation rate.
Source: WGS84, Table 3.1
"""

EARTH_MU = 3.986004418e14  # [m³/s²]
"""Earth gravitational parameter (GM).
Source: WGS84, Table 3.1
Note: More accurate than G*M_earth due to measurement precision
"""

# ============================================================================
# Atmospheric Parameters
# Source: US Standard Atmosphere 1976
# ============================================================================

SEA_LEVEL_PRESSURE = 101325.0  # [Pa]
"""Standard atmospheric pressure at sea level.
Source: US Standard Atmosphere 1976, NOAA-S/T 76-1562
"""

SEA_LEVEL_TEMPERATURE = 288.15  # [K] (15°C)
"""Standard temperature at sea level.
Source: US Standard Atmosphere 1976
"""

SEA_LEVEL_DENSITY = 1.225  # [kg/m³]
"""Standard air density at sea level.
Source: US Standard Atmosphere 1976
"""

GAS_CONSTANT_AIR = 287.05  # [J/(kg·K)]
"""Specific gas constant for dry air.
Source: US Standard Atmosphere 1976
Calculated from universal gas constant / molar mass of air
"""

# ============================================================================
# Conversion Factors
# ============================================================================

DEG_TO_RAD = np.pi / 180.0
RAD_TO_DEG = 180.0 / np.pi
FEET_TO_METERS = 0.3048  # exact by definition
METERS_TO_FEET = 1.0 / FEET_TO_METERS
KNOTS_TO_MPS = 0.514444  # nautical miles per hour to m/s
```

---



### Python Testing with pytest
```python
# tests/test_analysis.py
import pytest
from my_module import calculate_average

def test_calculate_average():
    """Test average calculation with normal input."""
    data = [1, 2, 3, 4, 5]
    result = calculate_average(data)
    assert result == 3.0

def test_calculate_average_empty():
    """Test average with empty list."""
    with pytest.raises(ValueError):
        calculate_average([])

# Run tests with: pytest tests/
```

### MATLAB Testing
```matlab
% tests/testCalculateAverage.m
function tests = testCalculateAverage
    tests = functiontests(localfunctions);
end

function testNormalInput(testCase)
    data = [1, 2, 3, 4, 5];
    expected = 3.0;
    actual = calculateAverage(data);
    testCase.verifyEqual(actual, expected, 'AbsTol', 1e-10);
end

function testEmptyInput(testCase)
    testCase.verifyError(@()calculateAverage([]), 'MATLAB:expectedNonempty');
end

% Run with: runtests('testCalculateAverage')
```

---

## Quick Reference Checklist

### Before Committing Code
- [ ] Code follows naming conventions
- [ ] Functions have docstrings/headers with physical context
- [ ] **REFERENCES.md updated with new sources**
- [ ] **Physical units and reference frames documented**
- [ ] **Notation correspondence table updated**
- [ ] No commented-out code left behind
- [ ] No debugging print statements
- [ ] Variables have meaningful names (including frame info)
- [ ] Complex logic has explanatory comments
- [ ] Equations reference source (e.g., "Eq. 3.2 from [1]")
- [ ] Tests pass (if applicable)
- [ ] No hardcoded file paths
- [ ] File is properly formatted

### Code Review Questions (Self-Check)
1. Will I understand this code in 6 months?
2. Are function names self-explanatory?
3. Is there duplicated code that should be refactored?
4. Are edge cases handled?
5. Could this be simpler?
6. **Are all physical assumptions documented?**
7. **Can I trace each equation back to its source?**
8. **Are coordinate systems clearly specified?**
9. **Are units consistent and documented?**

---

## Resources

### Python
- [PEP 8 Style Guide](https://pep8.org/)
- [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html)
- [Real Python Best Practices](https://realpython.com/)

### MATLAB
- [MATLAB Style Guidelines (Mathworks)](https://www.mathworks.com/matlabcentral/fileexchange/46056-matlab-style-guidelines-2-0)
- [MATLAB Programming Fundamentals](https://www.mathworks.com/help/matlab/programming-fundamentals.html)

### Tools
- **Python**: `black` (formatter), `pylint` (linter), `mypy` (type checker)
- **MATLAB**: Built-in Code Analyzer (checkcode)
- **Git**: Version control basics

---

*Last updated: February 2026*

---

## Addendum — conventions used by the /assist workflow

These come from the project that produced the workflow and complement the guide above.

- **Sections:** `%% 1. SECTION NAME` for main blocks; sub-sections as
  `% ─── Label ───────────────────` (box-drawing line to column 80).
- **Logging:** `fprintf('[Phase1] Description: %d x %d px\n', nRows, nCols)`; no stray debug prints.
- **Parameters:** one parameters file, sub-struct per block, each line `value; % [unit] meaning`; functions
  validate their sub-struct with `requireFields` and hold no defaults of their own.
- **Error identifiers:** `Project:function:Reason`, with a message that explains the theory behind the
  check, not just the symptom.
- **Tests:** one `matlab.unittest` class per block, named `t<Block>`, header with the physical context and
  the analytically expected values; test names are full sentences.
- **One figure per plot** when a journal target is confirmed (see plotting §0).
