# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src

# ▶ Lista completa de fuentes RTL (ajusta nombres si difieren)
PROJECT_SOURCES = \
  project.v \
  top.v \
  fsm.v \
  count_pulse2.v \
  count2.v \
  DelayCLK.v \
  C_1Hz.v \
  C_60s.v \
  Mux.v \
  Selec_auto.v \
  Dec_7seg.v \
  reg_dato.v \
  BintoDec.v \
  comparador.v \
  minuto.v

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD = sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else

# Gate level simulation:
SIM_BUILD = sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# este netlist lo deja el workflow de GDS:
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Include path para `project.v` y amigos
COMPILE_ARGS += -I$(SRC_DIR)

# Incluye tu testbench Verilog:
VERILOG_SOURCES += $(PWD)/tb.v

# Toplevel del simulador = tu testbench
TOPLEVEL = tb

# (Solo aplica si usas cocotb en Python; aquí no lo usamos)
MODULE = test

include $(shell cocotb-config --makefiles)/Makefile.sim
