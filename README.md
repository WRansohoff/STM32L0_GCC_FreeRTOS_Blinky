# Overview

This is one of ST's FreeRTOS example projects for the STM32L031K6 'Nucleo-32' board. It just blinks the on-board LED on and off every second.

ST didn't provide a way to build the project without an IDE, but they did provide enough templates and information to scrape together a minimal GCC project.

Despite being the same code, this Makefile seems to generate a ~24KB binary image, while AC6's Eclipse-based 'System Workbench' produces one which is only ~15KB. Maybe I'm including too many files or missing some settings. I'd like to make a more minimal example that doesn't rely on the large 'HAL' libraries.
