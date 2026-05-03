// Verso Design System - Figma Variables
// Creates proper Figma Variables (not just styles)

const colors = {
  'paper': {
    'background': { r: 0.961, g: 0.941, b: 0.910 },
    'text-primary': { r: 0.173, g: 0.161, b: 0.141 },
    'text-secondary': { r: 0.431, g: 0.404, b: 0.373 },
    'surface': { r: 0.929, g: 0.910, b: 0.875 },
    'accent': { r: 0.463, g: 0.400, b: 0.333 },
    'divider': { r: 0.867, g: 0.847, b: 0.808 },
    'error': { r: 0.753, g: 0.224, b: 0.169 },
    'warning': { r: 0.706, g: 0.325, b: 0.035 },
    'success': { r: 0.086, g: 0.396, b: 0.204 }
  },
  'sepia': {
    'background': { r: 0.949, g: 0.910, b: 0.835 },
    'text-primary': { r: 0.180, g: 0.125, b: 0.075 },
    'text-secondary': { r: 0.459, g: 0.369, b: 0.251 },
    'surface': { r: 0.910, g: 0.871, b: 0.780 },
    'accent': { r: 0.510, g: 0.353, b: 0.216 },
    'divider': { r: 0.851, g: 0.792, b: 0.675 },
    'error': { r: 0.753, g: 0.224, b: 0.169 },
    'warning': { r: 0.706, g: 0.325, b: 0.035 },
    'success': { r: 0.086, g: 0.396, b: 0.204 }
  },
  'night': {
    'background': { r: 0.110, g: 0.102, b: 0.086 },
    'text-primary': { r: 0.910, g: 0.878, b: 0.816 },
    'text-secondary': { r: 0.561, g: 0.537, b: 0.498 },
    'surface': { r: 0.145, g: 0.137, b: 0.125 },
    'accent': { r: 0.769, g: 0.663, b: 0.490 },
    'divider': { r: 0.180, g: 0.169, b: 0.149 },
    'error': { r: 0.973, g: 0.443, b: 0.443 },
    'warning': { r: 0.988, g: 0.827, b: 0.302 },
    'success': { r: 0.290, g: 0.871, b: 0.502 }
  },
  'ink': {
    'background': { r: 0.067, g: 0.078, b: 0.094 },
    'text-primary': { r: 0.894, g: 0.902, b: 0.922 },
    'text-secondary': { r: 0.494, g: 0.518, b: 0.573 },
    'surface': { r: 0.094, g: 0.110, b: 0.133 },
    'accent': { r: 0.482, g: 0.624, b: 0.831 },
    'divider': { r: 0.118, g: 0.133, b: 0.157 },
    'error': { r: 0.988, g: 0.506, b: 0.506 },
    'warning': { r: 0.965, g: 0.878, b: 0.369 },
    'success': { r: 0.408, g: 0.827, b: 0.569 }
  }
};

const spacing = {
  'xxs': 4, 'xs': 8, 'sm': 12,
  'md': 16, 'lg': 24, 'xl': 32,
  '2xl': 48, '3xl': 64
};

let total = 0;

// Create color collection with modes for each theme
const colorCollection = figma.variables.createVariableCollection('Verso/Colors');

// Add a mode for each theme
const modes = {};
for (const theme of Object.keys(colors)) {
  const modeId = colorCollection.addMode(theme);
  modes[theme] = modeId;
}

// Create color variables
for (const [role, rgb] of Object.entries(colors.paper)) {
  const variable = figma.variables.createVariable(
    'color/' + role,
    colorCollection,
    'COLOR'
  );
  
  // Set value for each theme mode
  for (const [theme, modeId] of Object.entries(modes)) {
    variable.setValueForMode(modeId, colors[theme][role]);
  }
  total++;
}

// Create spacing collection
const spacingCollection = figma.variables.createVariableCollection('Verso/Spacing');
const spacingModeId = spacingCollection.defaultModeId;

for (const [name, value] of Object.entries(spacing)) {
  const variable = figma.variables.createVariable(
    'spacing/' + name,
    spacingCollection,
    'FLOAT'
  );
  variable.setValueForMode(spacingModeId, value);
  total++;
}

figma.notify('Created ' + total + ' Figma Variables:\n36 colors (4 themes) + 8 spacing');
console.log('Done:', total, 'variables');