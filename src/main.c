#define SLOG_IMPLEMENTATION
#include "slog.h"

#include "engine.h"
#include "globals.h"
#include "raylib.h"
#include <assert.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

static void usage(const char *prog_name) {
  printf("Usage:\n"
         "    %s run  path/to/game\n"
         "    %s init new/game/path\n",
         prog_name, prog_name);
}

static bool verify_game_path(const char *game_path) {
  if (!DirectoryExists(game_path)) {
    error("Game path should be a directory!");
    return false;
  }

  if (!FileExists(TextFormat("%s/main.lua", game_path))) {
    error("Expected a main.lua to exist in the game directory!");
    return false;
  }

  return true;
}

static void slog_engine_handler(Slog_Record *record) {
  Engine *engine = record->ctx;

  /* src:line (dim) */
  printf(ANSI_DIM "%s:%d " ANSI_RESET, record->src.file, record->src.line);

  /* [ (dim) */
  printf(ANSI_DIM "[" ANSI_RESET);

  /* te::LEVEL (colored) */
  printf("te::");

  const char *level_color = "";
  const char *level_name = "";

  switch (record->level) {
  case SLOG_DEBUG:
    level_color = ANSI_CYAN;
    level_name = "debug";
    break;
  case SLOG_INFO:
    level_color = ANSI_GREEN;
    level_name = "info";
    break;
  case SLOG_WARNING:
    level_color = ANSI_YELLOW;
    level_name = "warn";
    break;
  case SLOG_ERROR:
    level_color = ANSI_RED;
    level_name = "error";
    break;
  case SLOG_FATAL:
    level_color = ANSI_MAGENTA;
    level_name = "fatal";
    engine->exit_code = 1;
    engine->running = false;
    break;
  }

  printf("%s%s%s", level_color, level_name, ANSI_RESET);

  /* ] (dim) */
  printf(ANSI_DIM "] " ANSI_RESET);

  /* message (no color) */
  vprintf(record->fmt, record->args);
  printf("\n");
}

int main(int argc, char *argv[]) {
  const char *prog_name = argv[0];

  Engine *engine;
  slog_set_handler(slog_engine_handler, .ctx = engine);

  if (argc != 2) {
    error("An incorrect number of arguments was provided!");
    usage(prog_name);
    return EXIT_FAILURE;
  }

  const char *game_path = argv[1];

  if (!verify_game_path(game_path)) {
    return EXIT_FAILURE;
  }

  engine = engine_init(game_path);
  int exit_code = engine_run(engine);
  engine_free(engine);

  return exit_code;
}
