#include "grid.h"
#include <assert.h>
#include <stdlib.h>
#include <string.h>

Grid *grid_init(int w, int h) {
  Grid *grid = malloc(sizeof(Grid) + (w * h * sizeof(Cell)));
  assert(grid != NULL);

  grid->w = w;
  grid->h = h;

  return grid;
}

void grid_set(Grid *grid, size_t x, size_t y, Cell cell) {
  grid->cells[y * grid->w + x] = cell;
}

void grid_fill(Grid *grid, Cell cell) {
  for (int y = 0; y < (int)grid->h; y++) {
    for (int x = 0; x < (int)grid->w; x++) {
      grid_set(grid, x, y, cell);
    }
  }
}

Texture grid_render_texture(Grid *grid) {
  Image image = GenImageColor(grid->w, grid->h, BLANK);
  unsigned char *image_data = image.data;

  for (int y = 0; y < (int)grid->h; y++) {
    for (int x = 0; x < (int)grid->w; x++) {
      Cell cell = grid->cells[y * grid->w + x];

      int pixel_offset = (y * grid->w + x) * 4;
      image_data[pixel_offset + 0] = cell.glyph; // R: character
      image_data[pixel_offset + 1] = cell.fg;    // G: fg color
      image_data[pixel_offset + 2] = cell.bg;    // B: bg color
      image_data[pixel_offset + 3] = 255;        // A: alpha
    }
  }

  Texture texture = LoadTextureFromImage(image);
  UnloadImage(image);

  return texture;
}

void grid_free(Grid *grid) { free(grid); }

void grid_print(Grid *grid, size_t x, size_t y, const char *text) {
  size_t cx = x;
  size_t cy = y;

  for (size_t i = 0; text[i] != '\0'; i++) {
    char c = text[i];

    switch (c) {
    case '\n': // Newline
      cx = x;
      cy++;
      break;

    case '\r': // Carriage return
      cx = x;
      break;

    case '\t': { // Tab (4-space aligned)
      const size_t TAB_WIDTH = 4;
      size_t next_tab = ((cx / TAB_WIDTH) + 1) * TAB_WIDTH;
      cx = next_tab;
      break;
    }

    case '\b': // Backspace
      if (cx > x)
        cx--;
      break;

    default:
      if (cx < grid->w && cy < grid->h) {
        grid_set(grid, cx, cy,
                 (Cell){
                     .glyph = (unsigned char)c,
                     .fg = 15,
                     .bg = 0,
                 });
      }
      cx++;
      break;
    }

    if (cy >= grid->h)
      break;
  }
}
