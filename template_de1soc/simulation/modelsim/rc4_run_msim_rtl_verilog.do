transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/pedri/OneDrive/햞ea\ de\ Trabalho/Lab4/RC4/template_de1soc {C:/Users/pedri/OneDrive/햞ea de Trabalho/Lab4/RC4/template_de1soc/s_memory.v}
vlog -sv -work work +incdir+C:/Users/pedri/OneDrive/햞ea\ de\ Trabalho/Lab4/RC4/template_de1soc {C:/Users/pedri/OneDrive/햞ea de Trabalho/Lab4/RC4/template_de1soc/ksa.sv}
vlog -sv -work work +incdir+C:/Users/pedri/OneDrive/햞ea\ de\ Trabalho/Lab4/RC4/template_de1soc {C:/Users/pedri/OneDrive/햞ea de Trabalho/Lab4/RC4/template_de1soc/initialize_s.sv}

