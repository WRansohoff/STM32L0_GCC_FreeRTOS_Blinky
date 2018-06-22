TARGET = main

# Default target chip.
# TODO: Support more chips and boards.
MCU ?= STM32L031K6

ifeq ($(MCU), STM32L031K6)
	MCU_FILES = STM32L031K6T6
	ST_MCU_DEF = STM32L031xx
	MCU_CLASS = L0
endif

# Define the linker script location and chip architecture.
LD_SCRIPT = $(MCU_FILES).ld
ifeq ($(MCU_CLASS), L0)
	MCU_SPEC = cortex-m0plus
endif

# Toolchain definitions (ARM bare metal defaults)
TOOLCHAIN = /usr
CC = $(TOOLCHAIN)/bin/arm-none-eabi-gcc
AS = $(TOOLCHAIN)/bin/arm-none-eabi-as
LD = $(TOOLCHAIN)/bin/arm-none-eabi-ld
OC = $(TOOLCHAIN)/bin/arm-none-eabi-objcopy
OD = $(TOOLCHAIN)/bin/arm-none-eabi-objdump
OS = $(TOOLCHAIN)/bin/arm-none-eabi-size

# Assembly directives.
ASFLAGS += -c
ASFLAGS += -O0
ASFLAGS += -mcpu=$(MCU_SPEC)
ASFLAGS += -mthumb
ASFLAGS += -mfloat-abi=soft
ASFLAGS += -Wall
# (Set error messages to appear on a single line.)
ASFLAGS += -fmessage-length=0
ASFLAGS += -DVVC_$(MCU_CLASS)

# C compilation directives
CFLAGS += -mcpu=$(MCU_SPEC)
CFLAGS += -mthumb
CFLAGS += -mfloat-abi=soft
CFLAGS += -Wall
CFLAGS += -Os
CFLAGS += -g
# (Set error messages to appear on a single line.)
CFLAGS += -fmessage-length=0
# (Set system to ignore semihosted junk)
CFLAGS += --specs=nosys.specs
CFLAGS += -D$(ST_MCU_DEF)
CFLAGS += -DVVC_$(MCU_CLASS)
CFLAGS += -DUSE_HAL_DRIVER
CFLAGS += -DUSE_STM32L0XX_NUCLEO_32

# Linker directives.
LSCRIPT = ./ld/$(LD_SCRIPT)
LFLAGS += -mcpu=$(MCU_SPEC)
LFLAGS += -mthumb
LFLAGS += -mfloat-abi=soft
LFLAGS += -Wall
LFLAGS += --specs=nosys.specs
#LFLAGS += -nostdlib
#LFLAGS += -lgcc
#LFLAGS += -lc
LFLAGS += -T$(LSCRIPT)

#AS_SRC   =  ./boot_code/$(MCU_FILES)_core.S
#AS_SRC   += ./vector_tables/$(MCU_FILES)_vt.S
AS_SRC   =  ./device_headers/startup_stm32l031xx.S
C_SRC    =  ./src/main.c
C_SRC    += ./src/stm32l0xx_it.c
C_SRC    += ./device_headers/system_stm32l0xx.c
C_SRC    += ./device_headers/BSP/stm32l0xx_nucleo_32.c
C_SRC    += ./device_headers/HAL/stm32l0xx_hal.c
C_SRC    += ./device_headers/HAL/stm32l0xx_hal_cortex.c
C_SRC    += ./device_headers/HAL/stm32l0xx_hal_gpio.c
C_SRC    += ./device_headers/HAL/stm32l0xx_hal_rcc.c
C_SRC    += ./device_headers/HAL/stm32l0xx_hal_rcc_ex.c
C_SRC    += ./FreeRTOS/cmsis_os.c
C_SRC    += ./FreeRTOS/heap_4.c
C_SRC    += ./FreeRTOS/list.c
C_SRC    += ./FreeRTOS/port.c
C_SRC    += ./FreeRTOS/queue.c
C_SRC    += ./FreeRTOS/tasks.c
C_SRC    += ./FreeRTOS/timers.c

INCLUDE  =  -I./
INCLUDE  += -I./FreeRTOS
INCLUDE  += -I./device_headers
INCLUDE  += -I./device_headers/BSP
INCLUDE  += -I./device_headers/HAL

OBJS  = $(AS_SRC:.S=.o)
OBJS += $(C_SRC:.c=.o)

.PHONY: all
all: $(TARGET).bin

%.o: %.S
	$(CC) -x assembler-with-cpp $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) -c $(CFLAGS) $(INCLUDE) $< -o $@

$(TARGET).elf: $(OBJS)
	$(CC) $^ $(LFLAGS) -o $@

$(TARGET).bin: $(TARGET).elf
	$(OC) -S -O binary $< $@
	$(OS) $<

.PHONY: clean
clean:
	rm -f $(OBJS)
	rm -f $(TARGET).elf
	rm -f $(TARGET).bin
