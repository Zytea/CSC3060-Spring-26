
bomb:     file format elf32-littleriscv


Disassembly of section .plt:

00010930 <_PROCEDURE_LINKAGE_TABLE_>:
   10930:	97 33 00 00 33 03 c3 41 03 ae 83 6c 13 03 43 fd     .3..3..A...l..C.
   10940:	93 82 83 6c 13 53 23 00 83 a2 42 00 67 00 0e 00     ...l.S#...B.g...

00010950 <strcasecmp@plt>:
   10950:	00003e17          	auipc	t3,0x3
   10954:	6b0e2e03          	lw	t3,1712(t3) # 14000 <strcasecmp@GLIBC_2.33>
   10958:	000e0367          	jalr	t1,t3
   1095c:	00000013          	nop

00010960 <read@plt>:
   10960:	00003e17          	auipc	t3,0x3
   10964:	6a4e2e03          	lw	t3,1700(t3) # 14004 <read@GLIBC_2.33>
   10968:	000e0367          	jalr	t1,t3
   1096c:	00000013          	nop

00010970 <fflush@plt>:
   10970:	00003e17          	auipc	t3,0x3
   10974:	698e2e03          	lw	t3,1688(t3) # 14008 <fflush@GLIBC_2.33>
   10978:	000e0367          	jalr	t1,t3
   1097c:	00000013          	nop

00010980 <__libc_start_main@plt>:
   10980:	00003e17          	auipc	t3,0x3
   10984:	68ce2e03          	lw	t3,1676(t3) # 1400c <__libc_start_main@GLIBC_2.34>
   10988:	000e0367          	jalr	t1,t3
   1098c:	00000013          	nop

00010990 <__isoc23_sscanf@plt>:
   10990:	00003e17          	auipc	t3,0x3
   10994:	680e2e03          	lw	t3,1664(t3) # 14010 <__isoc23_sscanf@GLIBC_2.38>
   10998:	000e0367          	jalr	t1,t3
   1099c:	00000013          	nop

000109a0 <printf@plt>:
   109a0:	00003e17          	auipc	t3,0x3
   109a4:	674e2e03          	lw	t3,1652(t3) # 14014 <printf@GLIBC_2.33>
   109a8:	000e0367          	jalr	t1,t3
   109ac:	00000013          	nop

000109b0 <write@plt>:
   109b0:	00003e17          	auipc	t3,0x3
   109b4:	668e2e03          	lw	t3,1640(t3) # 14018 <write@GLIBC_2.33>
   109b8:	000e0367          	jalr	t1,t3
   109bc:	00000013          	nop

000109c0 <alarm@plt>:
   109c0:	00003e17          	auipc	t3,0x3
   109c4:	65ce2e03          	lw	t3,1628(t3) # 1401c <alarm@GLIBC_2.33>
   109c8:	000e0367          	jalr	t1,t3
   109cc:	00000013          	nop

000109d0 <close@plt>:
   109d0:	00003e17          	auipc	t3,0x3
   109d4:	650e2e03          	lw	t3,1616(t3) # 14020 <close@GLIBC_2.33>
   109d8:	000e0367          	jalr	t1,t3
   109dc:	00000013          	nop

000109e0 <puts@plt>:
   109e0:	00003e17          	auipc	t3,0x3
   109e4:	644e2e03          	lw	t3,1604(t3) # 14024 <puts@GLIBC_2.33>
   109e8:	000e0367          	jalr	t1,t3
   109ec:	00000013          	nop

000109f0 <__ctype_b_loc@plt>:
   109f0:	00003e17          	auipc	t3,0x3
   109f4:	638e2e03          	lw	t3,1592(t3) # 14028 <__ctype_b_loc@GLIBC_2.33>
   109f8:	000e0367          	jalr	t1,t3
   109fc:	00000013          	nop

00010a00 <exit@plt>:
   10a00:	00003e17          	auipc	t3,0x3
   10a04:	62ce2e03          	lw	t3,1580(t3) # 1402c <exit@GLIBC_2.33>
   10a08:	000e0367          	jalr	t1,t3
   10a0c:	00000013          	nop

00010a10 <gethostname@plt>:
   10a10:	00003e17          	auipc	t3,0x3
   10a14:	620e2e03          	lw	t3,1568(t3) # 14030 <gethostname@GLIBC_2.33>
   10a18:	000e0367          	jalr	t1,t3
   10a1c:	00000013          	nop

00010a20 <sprintf@plt>:
   10a20:	00003e17          	auipc	t3,0x3
   10a24:	614e2e03          	lw	t3,1556(t3) # 14034 <sprintf@GLIBC_2.33>
   10a28:	000e0367          	jalr	t1,t3
   10a2c:	00000013          	nop

00010a30 <socket@plt>:
   10a30:	00003e17          	auipc	t3,0x3
   10a34:	608e2e03          	lw	t3,1544(t3) # 14038 <socket@GLIBC_2.33>
   10a38:	000e0367          	jalr	t1,t3
   10a3c:	00000013          	nop

00010a40 <signal@plt>:
   10a40:	00003e17          	auipc	t3,0x3
   10a44:	5fce2e03          	lw	t3,1532(t3) # 1403c <signal@GLIBC_2.33>
   10a48:	000e0367          	jalr	t1,t3
   10a4c:	00000013          	nop

00010a50 <fopen@plt>:
   10a50:	00003e17          	auipc	t3,0x3
   10a54:	5f0e2e03          	lw	t3,1520(t3) # 14040 <fopen@GLIBC_2.33>
   10a58:	000e0367          	jalr	t1,t3
   10a5c:	00000013          	nop

00010a60 <__isoc23_strtol@plt>:
   10a60:	00003e17          	auipc	t3,0x3
   10a64:	5e4e2e03          	lw	t3,1508(t3) # 14044 <__isoc23_strtol@GLIBC_2.38>
   10a68:	000e0367          	jalr	t1,t3
   10a6c:	00000013          	nop

00010a70 <memset@plt>:
   10a70:	00003e17          	auipc	t3,0x3
   10a74:	5d8e2e03          	lw	t3,1496(t3) # 14048 <memset@GLIBC_2.33>
   10a78:	000e0367          	jalr	t1,t3
   10a7c:	00000013          	nop

00010a80 <__errno_location@plt>:
   10a80:	00003e17          	auipc	t3,0x3
   10a84:	5cce2e03          	lw	t3,1484(t3) # 1404c <__errno_location@GLIBC_2.33>
   10a88:	000e0367          	jalr	t1,t3
   10a8c:	00000013          	nop

00010a90 <fprintf@plt>:
   10a90:	00003e17          	auipc	t3,0x3
   10a94:	5c0e2e03          	lw	t3,1472(t3) # 14050 <fprintf@GLIBC_2.33>
   10a98:	000e0367          	jalr	t1,t3
   10a9c:	00000013          	nop

00010aa0 <getenv@plt>:
   10aa0:	00003e17          	auipc	t3,0x3
   10aa4:	5b4e2e03          	lw	t3,1460(t3) # 14054 <getenv@GLIBC_2.33>
   10aa8:	000e0367          	jalr	t1,t3
   10aac:	00000013          	nop

00010ab0 <gethostbyname@plt>:
   10ab0:	00003e17          	auipc	t3,0x3
   10ab4:	5a8e2e03          	lw	t3,1448(t3) # 14058 <gethostbyname@GLIBC_2.33>
   10ab8:	000e0367          	jalr	t1,t3
   10abc:	00000013          	nop

00010ac0 <memcpy@plt>:
   10ac0:	00003e17          	auipc	t3,0x3
   10ac4:	59ce2e03          	lw	t3,1436(t3) # 1405c <memcpy@GLIBC_2.33>
   10ac8:	000e0367          	jalr	t1,t3
   10acc:	00000013          	nop

00010ad0 <strlen@plt>:
   10ad0:	00003e17          	auipc	t3,0x3
   10ad4:	590e2e03          	lw	t3,1424(t3) # 14060 <strlen@GLIBC_2.33>
   10ad8:	000e0367          	jalr	t1,t3
   10adc:	00000013          	nop

00010ae0 <fgets@plt>:
   10ae0:	00003e17          	auipc	t3,0x3
   10ae4:	584e2e03          	lw	t3,1412(t3) # 14064 <fgets@GLIBC_2.33>
   10ae8:	000e0367          	jalr	t1,t3
   10aec:	00000013          	nop

00010af0 <memmove@plt>:
   10af0:	00003e17          	auipc	t3,0x3
   10af4:	578e2e03          	lw	t3,1400(t3) # 14068 <memmove@GLIBC_2.33>
   10af8:	000e0367          	jalr	t1,t3
   10afc:	00000013          	nop

00010b00 <sleep@plt>:
   10b00:	00003e17          	auipc	t3,0x3
   10b04:	56ce2e03          	lw	t3,1388(t3) # 1406c <sleep@GLIBC_2.33>
   10b08:	000e0367          	jalr	t1,t3
   10b0c:	00000013          	nop

00010b10 <connect@plt>:
   10b10:	00003e17          	auipc	t3,0x3
   10b14:	560e2e03          	lw	t3,1376(t3) # 14070 <connect@GLIBC_2.33>
   10b18:	000e0367          	jalr	t1,t3
   10b1c:	00000013          	nop

00010b20 <strcmp@plt>:
   10b20:	00003e17          	auipc	t3,0x3
   10b24:	554e2e03          	lw	t3,1364(t3) # 14074 <strcmp@GLIBC_2.33>
   10b28:	000e0367          	jalr	t1,t3
   10b2c:	00000013          	nop

00010b30 <strcpy@plt>:
   10b30:	00003e17          	auipc	t3,0x3
   10b34:	548e2e03          	lw	t3,1352(t3) # 14078 <strcpy@GLIBC_2.33>
   10b38:	000e0367          	jalr	t1,t3
   10b3c:	00000013          	nop

Disassembly of section .text:

00010b40 <_start>:
   10b40:	2005                	jal	10b60 <load_gp>
   10b42:	87aa                	mv	a5,a0
   10b44:	00000517          	auipc	a0,0x0
   10b48:	01a50513          	add	a0,a0,26 # 10b5e <__wrap_main>
   10b4c:	4582                	lw	a1,0(sp)
   10b4e:	0050                	add	a2,sp,4
   10b50:	ff017113          	and	sp,sp,-16
   10b54:	4681                	li	a3,0
   10b56:	4701                	li	a4,0
   10b58:	880a                	mv	a6,sp
   10b5a:	351d                	jal	10980 <__libc_start_main@plt>
   10b5c:	9002                	ebreak

00010b5e <__wrap_main>:
   10b5e:	a08d                	j	10bc0 <main>

00010b60 <load_gp>:
   10b60:	00004197          	auipc	gp,0x4
   10b64:	d1c18193          	add	gp,gp,-740 # 1487c <__global_pointer$>
   10b68:	8082                	ret
   10b6a:	0001                	nop

00010b6c <_dl_relocate_static_pie>:
   10b6c:	8082                	ret

00010b6e <deregister_tm_clones>:
   10b6e:	b2018513          	add	a0,gp,-1248 # 1439c <__TMC_END__>
   10b72:	b2018793          	add	a5,gp,-1248 # 1439c <__TMC_END__>
   10b76:	00a78663          	beq	a5,a0,10b82 <deregister_tm_clones+0x14>
   10b7a:	00000793          	li	a5,0
   10b7e:	c391                	beqz	a5,10b82 <deregister_tm_clones+0x14>
   10b80:	8782                	jr	a5
   10b82:	8082                	ret

00010b84 <register_tm_clones>:
   10b84:	b2018513          	add	a0,gp,-1248 # 1439c <__TMC_END__>
   10b88:	b2018593          	add	a1,gp,-1248 # 1439c <__TMC_END__>
   10b8c:	8d89                	sub	a1,a1,a0
   10b8e:	4025d793          	sra	a5,a1,0x2
   10b92:	81fd                	srl	a1,a1,0x1f
   10b94:	95be                	add	a1,a1,a5
   10b96:	8585                	sra	a1,a1,0x1
   10b98:	c589                	beqz	a1,10ba2 <register_tm_clones+0x1e>
   10b9a:	00000793          	li	a5,0
   10b9e:	c391                	beqz	a5,10ba2 <register_tm_clones+0x1e>
   10ba0:	8782                	jr	a5
   10ba2:	8082                	ret

00010ba4 <__do_global_dtors_aux>:
   10ba4:	b481c703          	lbu	a4,-1208(gp) # 143c4 <completed.0>
   10ba8:	eb11                	bnez	a4,10bbc <__do_global_dtors_aux+0x18>
   10baa:	1141                	add	sp,sp,-16
   10bac:	c606                	sw	ra,12(sp)
   10bae:	37c1                	jal	10b6e <deregister_tm_clones>
   10bb0:	40b2                	lw	ra,12(sp)
   10bb2:	4705                	li	a4,1
   10bb4:	b4e18423          	sb	a4,-1208(gp) # 143c4 <completed.0>
   10bb8:	0141                	add	sp,sp,16
   10bba:	8082                	ret
   10bbc:	8082                	ret

00010bbe <frame_dummy>:
   10bbe:	b7d9                	j	10b84 <register_tm_clones>

00010bc0 <main>:
   10bc0:	1141                	add	sp,sp,-16
   10bc2:	c606                	sw	ra,12(sp)
   10bc4:	4785                	li	a5,1
   10bc6:	0af50863          	beq	a0,a5,10c76 <main+0xb6>
   10bca:	c422                	sw	s0,8(sp)
   10bcc:	842e                	mv	s0,a1
   10bce:	4789                	li	a5,2
   10bd0:	0cf51063          	bne	a0,a5,10c90 <main+0xd0>
   10bd4:	65c9                	lui	a1,0x12
   10bd6:	ae058593          	add	a1,a1,-1312 # 11ae0 <_IO_stdin_used+0x4>
   10bda:	4048                	lw	a0,4(s0)
   10bdc:	3d95                	jal	10a50 <fopen@plt>
   10bde:	b2a1a423          	sw	a0,-1240(gp) # 143a4 <infile>
   10be2:	08050f63          	beqz	a0,10c80 <main+0xc0>
   10be6:	4422                	lw	s0,8(sp)
   10be8:	2945                	jal	11098 <initialize_bomb>
   10bea:	6549                	lui	a0,0x12
   10bec:	b2050513          	add	a0,a0,-1248 # 11b20 <_IO_stdin_used+0x44>
   10bf0:	3bc5                	jal	109e0 <puts@plt>
   10bf2:	6549                	lui	a0,0x12
   10bf4:	b4c50513          	add	a0,a0,-1204 # 11b4c <_IO_stdin_used+0x70>
   10bf8:	33e5                	jal	109e0 <puts@plt>
   10bfa:	6549                	lui	a0,0x12
   10bfc:	b8c50513          	add	a0,a0,-1140 # 11b8c <_IO_stdin_used+0xb0>
   10c00:	3345                	jal	109a0 <printf@plt>
   10c02:	6549                	lui	a0,0x12
   10c04:	bd050513          	add	a0,a0,-1072 # 11bd0 <_IO_stdin_used+0xf4>
   10c08:	3be1                	jal	109e0 <puts@plt>
   10c0a:	6c8000ef          	jal	112d2 <read_line>
   10c0e:	2841                	jal	10c9e <phase_1>
   10c10:	79a000ef          	jal	113aa <phase_defused>
   10c14:	6549                	lui	a0,0x12
   10c16:	bf450513          	add	a0,a0,-1036 # 11bf4 <_IO_stdin_used+0x118>
   10c1a:	33d9                	jal	109e0 <puts@plt>
   10c1c:	6b6000ef          	jal	112d2 <read_line>
   10c20:	2045                	jal	10cc0 <phase_2>
   10c22:	788000ef          	jal	113aa <phase_defused>
   10c26:	6549                	lui	a0,0x12
   10c28:	c2850513          	add	a0,a0,-984 # 11c28 <_IO_stdin_used+0x14c>
   10c2c:	3b55                	jal	109e0 <puts@plt>
   10c2e:	6a4000ef          	jal	112d2 <read_line>
   10c32:	2a31                	jal	10d4e <phase_3>
   10c34:	776000ef          	jal	113aa <phase_defused>
   10c38:	6549                	lui	a0,0x12
   10c3a:	c5c50513          	add	a0,a0,-932 # 11c5c <_IO_stdin_used+0x180>
   10c3e:	334d                	jal	109e0 <puts@plt>
   10c40:	692000ef          	jal	112d2 <read_line>
   10c44:	220d                	jal	10d66 <phase_4>
   10c46:	764000ef          	jal	113aa <phase_defused>
   10c4a:	6549                	lui	a0,0x12
   10c4c:	c7850513          	add	a0,a0,-904 # 11c78 <_IO_stdin_used+0x19c>
   10c50:	3b41                	jal	109e0 <puts@plt>
   10c52:	680000ef          	jal	112d2 <read_line>
   10c56:	24b9                	jal	10ea4 <phase_5>
   10c58:	752000ef          	jal	113aa <phase_defused>
   10c5c:	6549                	lui	a0,0x12
   10c5e:	cac50513          	add	a0,a0,-852 # 11cac <_IO_stdin_used+0x1d0>
   10c62:	3bbd                	jal	109e0 <puts@plt>
   10c64:	66e000ef          	jal	112d2 <read_line>
   10c68:	2c8d                	jal	10eda <phase_6>
   10c6a:	740000ef          	jal	113aa <phase_defused>
   10c6e:	4501                	li	a0,0
   10c70:	40b2                	lw	ra,12(sp)
   10c72:	0141                	add	sp,sp,16
   10c74:	8082                	ret
   10c76:	b441a703          	lw	a4,-1212(gp) # 143c0 <stdin@GLIBC_2.33>
   10c7a:	b2e1a423          	sw	a4,-1240(gp) # 143a4 <infile>
   10c7e:	b7ad                	j	10be8 <main+0x28>
   10c80:	4050                	lw	a2,4(s0)
   10c82:	400c                	lw	a1,0(s0)
   10c84:	6549                	lui	a0,0x12
   10c86:	ae450513          	add	a0,a0,-1308 # 11ae4 <_IO_stdin_used+0x8>
   10c8a:	3b19                	jal	109a0 <printf@plt>
   10c8c:	4521                	li	a0,8
   10c8e:	3b8d                	jal	10a00 <exit@plt>
   10c90:	418c                	lw	a1,0(a1)
   10c92:	6549                	lui	a0,0x12
   10c94:	b0450513          	add	a0,a0,-1276 # 11b04 <_IO_stdin_used+0x28>
   10c98:	3321                	jal	109a0 <printf@plt>
   10c9a:	4521                	li	a0,8
   10c9c:	3395                	jal	10a00 <exit@plt>

00010c9e <phase_1>:
   10c9e:	1101                	add	sp,sp,-32
   10ca0:	ce06                	sw	ra,28(sp)
   10ca2:	0070                	add	a2,sp,12
   10ca4:	65c9                	lui	a1,0x12
   10ca6:	ce458593          	add	a1,a1,-796 # 11ce4 <_IO_stdin_used+0x208>
   10caa:	31dd                	jal	10990 <__isoc23_sscanf@plt>
   10cac:	4732                	lw	a4,12(sp)
   10cae:	33d00793          	li	a5,829
   10cb2:	00f71563          	bne	a4,a5,10cbc <phase_1+0x1e>
   10cb6:	40f2                	lw	ra,28(sp)
   10cb8:	6105                	add	sp,sp,32
   10cba:	8082                	ret
   10cbc:	23a5                	jal	11224 <explode_bomb>
   10cbe:	bfe5                	j	10cb6 <phase_1+0x18>

00010cc0 <phase_2>:
   10cc0:	7179                	add	sp,sp,-48
   10cc2:	d606                	sw	ra,44(sp)
   10cc4:	d422                	sw	s0,40(sp)
   10cc6:	d226                	sw	s1,36(sp)
   10cc8:	d04a                	sw	s2,32(sp)
   10cca:	002c                	add	a1,sp,8
   10ccc:	2bd1                	jal	112a0 <read_six_things>
   10cce:	47a2                	lw	a5,8(sp)
   10cd0:	0007c663          	bltz	a5,10cdc <phase_2+0x1c>
   10cd4:	0024                	add	s1,sp,8
   10cd6:	4405                	li	s0,1
   10cd8:	4919                	li	s2,6
   10cda:	a039                	j	10ce8 <phase_2+0x28>
   10cdc:	23a1                	jal	11224 <explode_bomb>
   10cde:	bfdd                	j	10cd4 <phase_2+0x14>
   10ce0:	0405                	add	s0,s0,1
   10ce2:	0491                	add	s1,s1,4
   10ce4:	01240963          	beq	s0,s2,10cf6 <phase_2+0x36>
   10ce8:	409c                	lw	a5,0(s1)
   10cea:	97a2                	add	a5,a5,s0
   10cec:	40d8                	lw	a4,4(s1)
   10cee:	fef709e3          	beq	a4,a5,10ce0 <phase_2+0x20>
   10cf2:	2b0d                	jal	11224 <explode_bomb>
   10cf4:	b7f5                	j	10ce0 <phase_2+0x20>
   10cf6:	50b2                	lw	ra,44(sp)
   10cf8:	5422                	lw	s0,40(sp)
   10cfa:	5492                	lw	s1,36(sp)
   10cfc:	5902                	lw	s2,32(sp)
   10cfe:	6145                	add	sp,sp,48
   10d00:	8082                	ret

00010d02 <aux_func3>:
   10d02:	1141                	add	sp,sp,-16
   10d04:	c606                	sw	ra,12(sp)
   10d06:	c422                	sw	s0,8(sp)
   10d08:	c226                	sw	s1,4(sp)
   10d0a:	c04a                	sw	s2,0(sp)
   10d0c:	84aa                	mv	s1,a0
   10d0e:	842e                	mv	s0,a1
   10d10:	26b5                	jal	1107c <string_length>
   10d12:	892a                	mv	s2,a0
   10d14:	8522                	mv	a0,s0
   10d16:	269d                	jal	1107c <string_length>
   10d18:	02a91063          	bne	s2,a0,10d38 <aux_func3+0x36>
   10d1c:	0004c783          	lbu	a5,0(s1)
   10d20:	c39d                	beqz	a5,10d46 <aux_func3+0x44>
   10d22:	00044703          	lbu	a4,0(s0)
   10d26:	02f71263          	bne	a4,a5,10d4a <aux_func3+0x48>
   10d2a:	0485                	add	s1,s1,1
   10d2c:	0405                	add	s0,s0,1
   10d2e:	0004c783          	lbu	a5,0(s1)
   10d32:	fbe5                	bnez	a5,10d22 <aux_func3+0x20>
   10d34:	4501                	li	a0,0
   10d36:	a011                	j	10d3a <aux_func3+0x38>
   10d38:	4505                	li	a0,1
   10d3a:	40b2                	lw	ra,12(sp)
   10d3c:	4422                	lw	s0,8(sp)
   10d3e:	4492                	lw	s1,4(sp)
   10d40:	4902                	lw	s2,0(sp)
   10d42:	0141                	add	sp,sp,16
   10d44:	8082                	ret
   10d46:	4501                	li	a0,0
   10d48:	bfcd                	j	10d3a <aux_func3+0x38>
   10d4a:	4505                	li	a0,1
   10d4c:	b7fd                	j	10d3a <aux_func3+0x38>

00010d4e <phase_3>:
   10d4e:	1141                	add	sp,sp,-16
   10d50:	c606                	sw	ra,12(sp)
   10d52:	65c9                	lui	a1,0x12
   10d54:	ce858593          	add	a1,a1,-792 # 11ce8 <_IO_stdin_used+0x20c>
   10d58:	376d                	jal	10d02 <aux_func3>
   10d5a:	e501                	bnez	a0,10d62 <phase_3+0x14>
   10d5c:	40b2                	lw	ra,12(sp)
   10d5e:	0141                	add	sp,sp,16
   10d60:	8082                	ret
   10d62:	21c9                	jal	11224 <explode_bomb>
   10d64:	bfe5                	j	10d5c <phase_3+0xe>

00010d66 <phase_4>:
   10d66:	1101                	add	sp,sp,-32
   10d68:	ce06                	sw	ra,28(sp)
   10d6a:	0038                	add	a4,sp,8
   10d6c:	00710693          	add	a3,sp,7
   10d70:	0070                	add	a2,sp,12
   10d72:	65c9                	lui	a1,0x12
   10d74:	d0858593          	add	a1,a1,-760 # 11d08 <_IO_stdin_used+0x22c>
   10d78:	3921                	jal	10990 <__isoc23_sscanf@plt>
   10d7a:	4789                	li	a5,2
   10d7c:	00a7de63          	bge	a5,a0,10d98 <phase_4+0x32>
   10d80:	4732                	lw	a4,12(sp) 
   10d82:	479d                	li	a5,7
   10d84:	0ce7e463          	bltu	a5,a4,10e4c <phase_4+0xe6>
   10d88:	00271793          	sll	a5,a4,0x2  # 索引 * 4 (计算地址偏移)
   10d8c:	6749                	lui	a4,0x12
   10d8e:	49070713          	add	a4,a4,1168 # 12490 <_IO_stdin_used+0x9b4>
   10d92:	97ba                	add	a5,a5,a4
   10d94:	439c                	lw	a5,0(a5)
   10d96:	8782                	jr	a5
   10d98:	2171                	jal	11224 <explode_bomb>
   10d9a:	b7dd                	j	10d80 <phase_4+0x1a>
   10d9c:	46a2                	lw	a3,8(sp)
   10d9e:	2f900713          	li	a4,761
   10da2:	06600793          	li	a5,102
   10da6:	0ae68663          	beq	a3,a4,10e52 <phase_4+0xec>
   10daa:	29ad                	jal	11224 <explode_bomb>
   10dac:	06600793          	li	a5,102
   10db0:	a04d                	j	10e52 <phase_4+0xec>
   10db2:	46a2                	lw	a3,8(sp)
   10db4:	1e200713          	li	a4,482
   10db8:	06f00793          	li	a5,111
   10dbc:	08e68b63          	beq	a3,a4,10e52 <phase_4+0xec>
   10dc0:	2195                	jal	11224 <explode_bomb>
   10dc2:	06f00793          	li	a5,111
   10dc6:	a071                	j	10e52 <phase_4+0xec>
   10dc8:	46a2                	lw	a3,8(sp)
   10dca:	2e600713          	li	a4,742
   10dce:	06500793          	li	a5,101
   10dd2:	08e68063          	beq	a3,a4,10e52 <phase_4+0xec>
   10dd6:	21b9                	jal	11224 <explode_bomb>
   10dd8:	06500793          	li	a5,101
   10ddc:	a89d                	j	10e52 <phase_4+0xec>
   10dde:	46a2                	lw	a3,8(sp)
   10de0:	24800713          	li	a4,584
   10de4:	06f00793          	li	a5,111
   10de8:	06e68563          	beq	a3,a4,10e52 <phase_4+0xec>
   10dec:	2925                	jal	11224 <explode_bomb>
   10dee:	06f00793          	li	a5,111
   10df2:	a085                	j	10e52 <phase_4+0xec>
   10df4:	46a2                	lw	a3,8(sp)
   10df6:	1ae00713          	li	a4,430
   10dfa:	06900793          	li	a5,105
   10dfe:	04e68a63          	beq	a3,a4,10e52 <phase_4+0xec>
   10e02:	210d                	jal	11224 <explode_bomb>
   10e04:	06900793          	li	a5,105
   10e08:	a0a9                	j	10e52 <phase_4+0xec>
   10e0a:	46a2                	lw	a3,8(sp)
   10e0c:	11600713          	li	a4,278
   10e10:	06100793          	li	a5,97
   10e14:	02e68f63          	beq	a3,a4,10e52 <phase_4+0xec>
   10e18:	2131                	jal	11224 <explode_bomb>
   10e1a:	06100793          	li	a5,97
   10e1e:	a815                	j	10e52 <phase_4+0xec>
   10e20:	46a2                	lw	a3,8(sp)
   10e22:	0b300713          	li	a4,179
   10e26:	07600793          	li	a5,118
   10e2a:	02e68463          	beq	a3,a4,10e52 <phase_4+0xec>
   10e2e:	2edd                	jal	11224 <explode_bomb>
   10e30:	07600793          	li	a5,118
   10e34:	a839                	j	10e52 <phase_4+0xec>
   10e36:	46a2                	lw	a3,8(sp)
   10e38:	3d300713          	li	a4,979
   10e3c:	07100793          	li	a5,113
   10e40:	00e68963          	beq	a3,a4,10e52 <phase_4+0xec>
   10e44:	26c5                	jal	11224 <explode_bomb>
   10e46:	07100793          	li	a5,113
   10e4a:	a021                	j	10e52 <phase_4+0xec>
   10e4c:	2ee1                	jal	11224 <explode_bomb>
   10e4e:	06200793          	li	a5,98
   10e52:	00714703          	lbu	a4,7(sp)
   10e56:	00f71563          	bne	a4,a5,10e60 <phase_4+0xfa>
   10e5a:	40f2                	lw	ra,28(sp)
   10e5c:	6105                	add	sp,sp,32
   10e5e:	8082                	ret
   10e60:	26d1                	jal	11224 <explode_bomb>
   10e62:	bfe5                	j	10e5a <phase_4+0xf4>

00010e64 <aux_func5>:
   10e64:	02a05e63          	blez	a0,10ea0 <aux_func5+0x3c> # if (n <= 0) return 0;
   10e68:	1141                	add	sp,sp,-16
   10e6a:	c606                	sw	ra,12(sp)
   10e6c:	c422                	sw	s0,8(sp)
   10e6e:	c226                	sw	s1,4(sp)
   10e70:	842a                	mv	s0,a0
   10e72:	84ae                	mv	s1,a1
   10e74:	4785                	li	a5,1
   10e76:	852e                	mv	a0,a1
   10e78:	00f40f63          	beq	s0,a5,10e96 <aux_func5+0x32> # if (n == 1) return y;
   10e7c:	c04a                	sw	s2,0(sp)
   10e7e:	fff40513          	add	a0,s0,-1
   10e82:	37cd                	jal	10e64 <aux_func5>
   10e84:	009507b3          	add	a5,a0,s1 
   10e88:	893e                	mv	s2,a5 # s2 = aux_func5(n - 1, y) + y;
   10e8a:	85a6                	mv	a1,s1
   10e8c:	ffe40513          	add	a0,s0,-2
   10e90:	3fd1                	jal	10e64 <aux_func5>
   10e92:	954a                	add	a0,a0,s2 # a0 = aux_func5(n - 2, y) + s2;
   10e94:	4902                	lw	s2,0(sp)    # f(n, y) = f(n-1, y) + y + f(n-2, y);
   10e96:	40b2                	lw	ra,12(sp)
   10e98:	4422                	lw	s0,8(sp)
   10e9a:	4492                	lw	s1,4(sp)
   10e9c:	0141                	add	sp,sp,16
   10e9e:	8082                	ret
   10ea0:	4501                	li	a0,0
   10ea2:	8082                	ret

00010ea4 <phase_5>:
   10ea4:	1101                	add	sp,sp,-32
   10ea6:	ce06                	sw	ra,28(sp)
   10ea8:	0074                	add	a3,sp,12
   10eaa:	0030                	add	a2,sp,8
   10eac:	65c9                	lui	a1,0x12
   10eae:	01858593          	add	a1,a1,24 # 12018 <_IO_stdin_used+0x53c>
   10eb2:	3cf9                	jal	10990 <__isoc23_sscanf@plt>
   10eb4:	4789                	li	a5,2
   10eb6:	00f51663          	bne	a0,a5,10ec2 <phase_5+0x1e>
   10eba:	47b2                	lw	a5,12(sp)
   10ebc:	17f9                	add	a5,a5,-2
   10ebe:	00f57363          	bgeu	a0,a5,10ec4 <phase_5+0x20>
   10ec2:	268d                	jal	11224 <explode_bomb>
   10ec4:	45b2                	lw	a1,12(sp)
   10ec6:	4519                	li	a0,6
   10ec8:	3f71                	jal	10e64 <aux_func5>
   10eca:	47a2                	lw	a5,8(sp)
   10ecc:	00a79563          	bne	a5,a0,10ed6 <phase_5+0x32>
   10ed0:	40f2                	lw	ra,28(sp)
   10ed2:	6105                	add	sp,sp,32
   10ed4:	8082                	ret
   10ed6:	26b9                	jal	11224 <explode_bomb>
   10ed8:	bfe5                	j	10ed0 <phase_5+0x2c>

00010eda <phase_6>:
   10eda:	711d                	add	sp,sp,-96
   10edc:	ce86                	sw	ra,92(sp)
   10ede:	cca2                	sw	s0,88(sp)
   10ee0:	caa6                	sw	s1,84(sp)
   10ee2:	c8ca                	sw	s2,80(sp)
   10ee4:	c6ce                	sw	s3,76(sp)
   10ee6:	c4d2                	sw	s4,72(sp)
   10ee8:	c2d6                	sw	s5,68(sp)
   10eea:	c0da                	sw	s6,64(sp)
   10eec:	de5e                	sw	s7,60(sp)
   10eee:	dc62                	sw	s8,56(sp)
   10ef0:	01810c13          	add	s8,sp,24
   10ef4:	85e2                	mv	a1,s8
   10ef6:	266d                	jal	112a0 <read_six_things>
   10ef8:	8ae2                	mv	s5,s8
   10efa:	01c10a13          	add	s4,sp,28
   10efe:	4b05                	li	s6,1
   10f00:	4b95                	li	s7,5
   10f02:	4999                	li	s3,6
   10f04:	a059                	j	10f8a <phase_6+0xb0>
   10f06:	2e39                	jal	11224 <explode_bomb>
   10f08:	845a                	mv	s0,s6
   10f0a:	096bd963          	bge	s7,s6,10f9c <phase_6+0xc2>
   
   # --- 6 校验完后
   # `node1` 基址是 `0x1407c`
   # 对每个输入 `k=p[i]`：从 `node1` 开始走 `k-1` 次 `next`，得到第 k 个节点指针
   # 把 6 个节点指针按输入顺序写到栈上 `sp, sp+4, ..., sp+20`
   10f0e:	860a                	mv	a2,sp                         # a2 = &ptrs[0]（把 node* 数组放在 sp 起）
   10f10:	0c61                	add	s8,s8,24                   # s8 = &p[6]（p 数组末尾，用于停止）
   10f12:	4505                	li	a0,1                          # a0 = 1 (i 从 1 开始)
   10f14:	65d1                	lui	a1,0x14
   10f16:	000aa683          	lw	a3,0(s5)                      # a3 = p[0]（p 数组起始）k=p[i]
   10f1a:	4785                	li	a5,1                          # a5 = 1 (j 从 1 开始)
   10f1c:	07c58713          	add	a4,a1,124 # 1407c <node1>
   10f20:	04d55563          	bge	a0,a3,10f6a <phase_6+0x90> # if (1 >= k) 说明 k==1 -> 直接 node1
   # 否则走 next 直到到第 k 个 node
   10f24:	4718                	lw	a4,8(a4)                      # a4 = a4->next
   10f26:	0785                	add	a5,a5,1                    # j++
   10f28:	fed79ee3          	bne	a5,a3,10f24 <phase_6+0x4a> # 如果 j != k 继续走 next

   10f2c:	c218                	sw	a4,0(a2)                      # ptrs[i] = a4（第 k 个节点）
   10f2e:	0a91                	add	s5,s5,4                    # s5 指向下一个输入 p[i+1]
   10f30:	0611                	add	a2,a2,4                    # a2 指向 ptrs[i+1]
   10f32:	ff8a92e3          	bne	s5,s8,10f16 <phase_6+0x3c> # 直到 6 个都处理完

   # --- 8 重链（按 ptrs[0..5] 重新设置 next）
   10f36:	4402                	lw	s0,0(sp)  # s0 = ptrs[0]（当前节点）
   10f38:	4792                	lw	a5,4(sp)  # a5 = ptrs[1]（下一个节点）
   10f3a:	c41c                	sw	a5,8(s0)  # s0->next = a5
   10f3c:	4722                	lw	a4,8(sp)  # a4 = ptrs[2]（下下个节点）
   10f3e:	c798                	sw	a4,8(a5)
   10f40:	47b2                	lw	a5,12(sp)
   10f42:	c71c                	sw	a5,8(a4)
   10f44:	4742                	lw	a4,16(sp)   # a4 = ptrs[4]
   10f46:	c798                	sw	a4,8(a5)   # ptrs[3]->next = ptrs[4]
   10f48:	47d2                	lw	a5,20(sp)  # a5 = ptrs[5]（最后一个节点）
   10f4a:	c71c                	sw	a5,8(a4)   # ptrs[4]->next = ptrs[5]
   10f4c:	0007a423          	sw	zero,8(a5) # ptrs[5]->next = NULL
   # --- 9 检查 value 非递增（降序）
   10f50:	4495                	li	s1,5       # s1 用来遍历 ptrs[1..5]（比较 ptrs[i-1] 和 ptrs[i]）
   10f52:	a01d                	j	10f78 <phase_6+0x9e>

   # --- 4
   10f54:	0405                	add	s0,s0,1 # j++
   10f56:	0491                	add	s1,s1,4 # s1 指向下一个 p[j]
   10f58:	03340763          	beq	s0,s3,10f86 <phase_6+0xac>  # if j == 6 说明比完了 -> 外层下一轮
   # --- 3 inner loop: 比较 p[i-1] 与 p[i], p[i+1] ... p[5]
   10f5c:	ffc92703          	lw	a4,-4(s2) # a4 = p[i-1]
   10f60:	409c                	lw	a5,0(s1) # a5 = p[j]
   10f62:	fef719e3          	bne	a4,a5,10f54 <phase_6+0x7a> # 如果不相等 (安全)，继续下一轮
   10f66:	2c7d                	jal	11224 <explode_bomb>
   10f68:	b7f5                	j	10f54 <phase_6+0x7a>

   # --- 7 做node1
   10f6a:	6751                	lui	a4,0x14
   10f6c:	07c70713          	add	a4,a4,124 # 1407c <node1>
   10f70:	bf75                	j	10f2c <phase_6+0x52>

   # --- 11
   10f72:	4400                	lw	s0,8(s0)     # s0 = s0->next
   10f74:	14fd                	add	s1,s1,-1
   10f76:	c48d                	beqz	s1,10fa0 <phase_6+0xc6> # 比完 5 次就通过
   
   # --- 10
   10f78:	441c                	lw	a5,8(s0) # a5 = s0->next
   10f7a:	4018                	lw	a4,0(s0) # a4 = s0->value
   10f7c:	439c                	lw	a5,0(a5) # a5 = next->value
   10f7e:	fef75ae3          	bge	a4,a5,10f72 <phase_6+0x98> # if (cur.value >= next.value) ok
   10f82:	244d                	jal	11224 <explode_bomb>
   10f84:	b7fd                	j	10f72 <phase_6+0x98>

   # --- 5 to next outer loop
   10f86:	0b05                	add	s6,s6,1 # i++
   10f88:	0a11                	add	s4,s4,4 # s4 指向下一项（&p[i]）
   # --- 2 outer loop
   10f8a:	8952                	mv	s2,s4
   10f8c:	ffca2783          	lw	a5,-4(s4) # 读取当前遍历到的输入数字
   10f90:	17fd                	add	a5,a5,-1 # # a5 = p[i-1]-1
   10f92:	f6fbeae3          	bltu	s7,a5,10f06 <phase_6+0x2c> # 1 to 6
   10f96:	845a                	mv	s0,s6  # s0 j = i（从 s6 开始计数）
   10f98:	f76bcbe3          	blt	s7,s6,10f0e <phase_6+0x34> # if (s6 > 5) 跳出（对应检查最后一个元素 p[5]）
   10f9c:	84d2                	mv	s1,s4 # s1 = &p[i]（inner loop 指针）
   10f9e:	bf7d                	j	10f5c <phase_6+0x82> # 进入 inner loop
   
   # --- 收尾
   10fa0:	40f6                	lw	ra,92(sp)
   10fa2:	4466                	lw	s0,88(sp)
   10fa4:	44d6                	lw	s1,84(sp)
   10fa6:	4946                	lw	s2,80(sp)
   10fa8:	49b6                	lw	s3,76(sp)
   10faa:	4a26                	lw	s4,72(sp)
   10fac:	4a96                	lw	s5,68(sp)
   10fae:	4b06                	lw	s6,64(sp)
   10fb0:	5bf2                	lw	s7,60(sp)
   10fb2:	5c62                	lw	s8,56(sp)
   10fb4:	6125                	add	sp,sp,96
   10fb6:	8082                	ret

00010fb8 <aux_secret>:
   10fb8:	c515                	beqz	a0,10fe4 <aux_secret+0x2c>    # if (node==NULL) return -1
   10fba:	1141                	add	sp,sp,-16
   10fbc:	c606                	sw	ra,12(sp)
   10fbe:	87aa                	mv	a5,a0                            # a5 = 保存 node 指针（后面走右子树会用）
   10fc0:	4118                	lw	a4,0(a0)                         # a4 = node->value
   10fc2:	00e5c863          	blt	a1,a4,10fd2 <aux_secret+0x1a> # if (x < value) goto left
   10fc6:	4501                	li	a0,0                             # a0 = 0（默认：x==value 的返回值）
   10fc8:	00b71963          	bne	a4,a1,10fda <aux_secret+0x22> # if (value != x) goto right（即 x > value）
   # --- x == value
   10fcc:	40b2                	lw	ra,12(sp)
   10fce:	0141                	add	sp,sp,16
   10fd0:	8082                	ret
   # --- left: return aux(left,x) << 1
   10fd2:	4148                	lw	a0,4(a0)
   10fd4:	37d5                	jal	10fb8 <aux_secret>
   10fd6:	0506                	sll	a0,a0,0x1
   10fd8:	bfd5                	j	10fcc <aux_secret+0x14>
   # --- right：return (aux(right,x) << 1) + 1
   10fda:	4788                	lw	a0,8(a5)
   10fdc:	3ff1                	jal	10fb8 <aux_secret>
   10fde:	0506                	sll	a0,a0,0x1
   10fe0:	0505                	add	a0,a0,1
   10fe2:	b7ed                	j	10fcc <aux_secret+0x14>
   # ---
   10fe4:	557d                	li	a0,-1
   10fe6:	8082                	ret

00010fe8 <secret_phase>:
   10fe8:	1141                	add	sp,sp,-16
   10fea:	c606                	sw	ra,12(sp)
   10fec:	c422                	sw	s0,8(sp)
   10fee:	24d5                	jal	112d2 <read_line>           # 读一行，返回 char* 在 a0
   10ff0:	4629                	li	a2,10                          # base = 10
   10ff2:	4581                	li	a1,0                           # endptr = NULL
   10ff4:	34b5                	jal	10a60 <__isoc23_strtol@plt> # a0 = strtol(line, NULL, 10)
   10ff6:	842a                	mv	s0,a0                          # s0 = x
   10ff8:	fff50713          	add	a4,a0,-1
   10ffc:	3e800793          	li	a5,1000
   11000:	02e7e363          	bltu	a5,a4,11026 <secret_phase+0x3e> # if ((unsigned)(x-1) > 1000) explode 所以 1-1000
   11004:	85a2                	mv	a1,s0
   11006:	80c18513          	add	a0,gp,-2036 # 14088 <n1>
   1100a:	377d                	jal	10fb8 <aux_secret>              # code = aux_secret(n1, x)
   1100c:	4791                	li	a5,4
   1100e:	00f51e63          	bne	a0,a5,1102a <secret_phase+0x42> # if (code != 4) explode
   11012:	6549                	lui	a0,0x12
   11014:	d1450513          	add	a0,a0,-748 # 11d14 <_IO_stdin_used+0x238>
   11018:	9c9ff0ef          	jal	109e0 <puts@plt>
   1101c:	2679                	jal	113aa <phase_defused>
   1101e:	40b2                	lw	ra,12(sp)
   11020:	4422                	lw	s0,8(sp)
   11022:	0141                	add	sp,sp,16
   11024:	8082                	ret
   11026:	2afd                	jal	11224 <explode_bomb>
   11028:	bff1                	j	11004 <secret_phase+0x1c>
   1102a:	2aed                	jal	11224 <explode_bomb>
   1102c:	b7dd                	j	11012 <secret_phase+0x2a>

0001102e <sig_handler>:
   1102e:	1141                	add	sp,sp,-16
   11030:	c606                	sw	ra,12(sp)
   11032:	6549                	lui	a0,0x12
   11034:	d3c50513          	add	a0,a0,-708 # 11d3c <_IO_stdin_used+0x260>
   11038:	9a9ff0ef          	jal	109e0 <puts@plt>
   1103c:	450d                	li	a0,3
   1103e:	34c9                	jal	10b00 <sleep@plt>
   11040:	6549                	lui	a0,0x12
   11042:	d7450513          	add	a0,a0,-652 # 11d74 <_IO_stdin_used+0x298>
   11046:	95bff0ef          	jal	109a0 <printf@plt>
   1104a:	b341a503          	lw	a0,-1228(gp) # 143b0 <stdout@GLIBC_2.33>
   1104e:	923ff0ef          	jal	10970 <fflush@plt>
   11052:	4505                	li	a0,1
   11054:	3475                	jal	10b00 <sleep@plt>
   11056:	6549                	lui	a0,0x12
   11058:	d7c50513          	add	a0,a0,-644 # 11d7c <_IO_stdin_used+0x2a0>
   1105c:	985ff0ef          	jal	109e0 <puts@plt>
   11060:	4541                	li	a0,16
   11062:	99fff0ef          	jal	10a00 <exit@plt>

00011066 <invalid_phase>:
   11066:	1141                	add	sp,sp,-16
   11068:	c606                	sw	ra,12(sp)
   1106a:	85aa                	mv	a1,a0
   1106c:	6549                	lui	a0,0x12
   1106e:	d8450513          	add	a0,a0,-636 # 11d84 <_IO_stdin_used+0x2a8>
   11072:	92fff0ef          	jal	109a0 <printf@plt>
   11076:	4521                	li	a0,8
   11078:	989ff0ef          	jal	10a00 <exit@plt>

0001107c <string_length>:
   1107c:	872a                	mv	a4,a0
   1107e:	00054783          	lbu	a5,0(a0)
   11082:	cb89                	beqz	a5,11094 <string_length+0x18>
   11084:	4501                	li	a0,0
   11086:	0505                	add	a0,a0,1
   11088:	00a707b3          	add	a5,a4,a0
   1108c:	0007c783          	lbu	a5,0(a5)
   11090:	fbfd                	bnez	a5,11086 <string_length+0xa>
   11092:	8082                	ret
   11094:	4501                	li	a0,0
   11096:	8082                	ret

00011098 <initialize_bomb>:
   11098:	715d                	add	sp,sp,-80
   1109a:	c686                	sw	ra,76(sp)
   1109c:	c4a2                	sw	s0,72(sp)
   1109e:	c2a6                	sw	s1,68(sp)
   110a0:	72f9                	lui	t0,0xffffe
   110a2:	9116                	add	sp,sp,t0
   110a4:	65c5                	lui	a1,0x11
   110a6:	02e58593          	add	a1,a1,46 # 1102e <sig_handler>
   110aa:	4509                	li	a0,2
   110ac:	995ff0ef          	jal	10a40 <signal@plt>
   110b0:	04000593          	li	a1,64
   110b4:	6789                	lui	a5,0x2
   110b6:	00f10533          	add	a0,sp,a5
   110ba:	957ff0ef          	jal	10a10 <gethostname@plt>
   110be:	e90d                	bnez	a0,110f0 <initialize_bomb+0x58>
   110c0:	9201a503          	lw	a0,-1760(gp) # 1419c <host_table>
   110c4:	cd11                	beqz	a0,110e0 <initialize_bomb+0x48>
   110c6:	92418413          	add	s0,gp,-1756 # 141a0 <host_table+0x4>
   110ca:	6789                	lui	a5,0x2
   110cc:	00f104b3          	add	s1,sp,a5
   110d0:	85a6                	mv	a1,s1
   110d2:	87fff0ef          	jal	10950 <strcasecmp@plt>
   110d6:	cd15                	beqz	a0,11112 <initialize_bomb+0x7a>
   110d8:	0411                	add	s0,s0,4
   110da:	ffc42503          	lw	a0,-4(s0)
   110de:	f96d                	bnez	a0,110d0 <initialize_bomb+0x38>
   110e0:	6549                	lui	a0,0x12
   110e2:	dd050513          	add	a0,a0,-560 # 11dd0 <_IO_stdin_used+0x2f4>
   110e6:	8fbff0ef          	jal	109e0 <puts@plt>
   110ea:	4521                	li	a0,8
   110ec:	915ff0ef          	jal	10a00 <exit@plt>
   110f0:	6549                	lui	a0,0x12
   110f2:	d9850513          	add	a0,a0,-616 # 11d98 <_IO_stdin_used+0x2bc>
   110f6:	8ebff0ef          	jal	109e0 <puts@plt>
   110fa:	4521                	li	a0,8
   110fc:	905ff0ef          	jal	10a00 <exit@plt>
   11100:	858a                	mv	a1,sp
   11102:	6549                	lui	a0,0x12
   11104:	e0850513          	add	a0,a0,-504 # 11e08 <_IO_stdin_used+0x32c>
   11108:	899ff0ef          	jal	109a0 <printf@plt>
   1110c:	4521                	li	a0,8
   1110e:	8f3ff0ef          	jal	10a00 <exit@plt>
   11112:	850a                	mv	a0,sp
   11114:	057000ef          	jal	1196a <init_driver>
   11118:	fe0544e3          	bltz	a0,11100 <initialize_bomb+0x68>
   1111c:	6289                	lui	t0,0x2
   1111e:	9116                	add	sp,sp,t0
   11120:	40b6                	lw	ra,76(sp)
   11122:	4426                	lw	s0,72(sp)
   11124:	4496                	lw	s1,68(sp)
   11126:	6161                	add	sp,sp,80
   11128:	8082                	ret

0001112a <initialize_bomb_solve>:
   1112a:	8082                	ret

0001112c <blank_line>:
   1112c:	1141                	add	sp,sp,-16
   1112e:	c606                	sw	ra,12(sp)
   11130:	c422                	sw	s0,8(sp)
   11132:	c226                	sw	s1,4(sp)
   11134:	c04a                	sw	s2,0(sp)
   11136:	84aa                	mv	s1,a0
   11138:	6909                	lui	s2,0x2
   1113a:	0004c403          	lbu	s0,0(s1)
   1113e:	cc11                	beqz	s0,1115a <blank_line+0x2e>
   11140:	8b1ff0ef          	jal	109f0 <__ctype_b_loc@plt>
   11144:	0485                	add	s1,s1,1
   11146:	411c                	lw	a5,0(a0)
   11148:	0406                	sll	s0,s0,0x1
   1114a:	97a2                	add	a5,a5,s0
   1114c:	0007d783          	lhu	a5,0(a5) # 2000 <_PROCEDURE_LINKAGE_TABLE_-0xe930>
   11150:	0127f7b3          	and	a5,a5,s2
   11154:	f3fd                	bnez	a5,1113a <blank_line+0xe>
   11156:	4501                	li	a0,0
   11158:	a011                	j	1115c <blank_line+0x30>
   1115a:	4505                	li	a0,1
   1115c:	40b2                	lw	ra,12(sp)
   1115e:	4422                	lw	s0,8(sp)
   11160:	4492                	lw	s1,4(sp)
   11162:	4902                	lw	s2,0(sp)
   11164:	0141                	add	sp,sp,16
   11166:	8082                	ret

00011168 <skip>:
   11168:	1101                	add	sp,sp,-32
   1116a:	ce06                	sw	ra,28(sp)
   1116c:	cc22                	sw	s0,24(sp)
   1116e:	ca26                	sw	s1,20(sp)
   11170:	c84a                	sw	s2,16(sp)
   11172:	c64e                	sw	s3,12(sp)
   11174:	c452                	sw	s4,8(sp)
   11176:	b4c18493          	add	s1,gp,-1204 # 143c8 <input_strings>
   1117a:	05000913          	li	s2,80
   1117e:	b2c1a783          	lw	a5,-1236(gp) # 143a8 <num_input_strings>
   11182:	00279513          	sll	a0,a5,0x2
   11186:	953e                	add	a0,a0,a5
   11188:	0512                	sll	a0,a0,0x4
   1118a:	b281a603          	lw	a2,-1240(gp) # 143a4 <infile>
   1118e:	85ca                	mv	a1,s2
   11190:	9526                	add	a0,a0,s1
   11192:	94fff0ef          	jal	10ae0 <fgets@plt>
   11196:	842a                	mv	s0,a0
   11198:	c119                	beqz	a0,1119e <skip+0x36>
   1119a:	3f49                	jal	1112c <blank_line>
   1119c:	f16d                	bnez	a0,1117e <skip+0x16>
   1119e:	8522                	mv	a0,s0
   111a0:	40f2                	lw	ra,28(sp)
   111a2:	4462                	lw	s0,24(sp)
   111a4:	44d2                	lw	s1,20(sp)
   111a6:	4942                	lw	s2,16(sp)
   111a8:	49b2                	lw	s3,12(sp)
   111aa:	4a22                	lw	s4,8(sp)
   111ac:	6105                	add	sp,sp,32
   111ae:	8082                	ret

000111b0 <send_msg>:
   111b0:	1141                	add	sp,sp,-16
   111b2:	c606                	sw	ra,12(sp)
   111b4:	c422                	sw	s0,8(sp)
   111b6:	72f1                	lui	t0,0xffffc
   111b8:	9116                	add	sp,sp,t0
   111ba:	b2c1a703          	lw	a4,-1236(gp) # 143a8 <num_input_strings>
   111be:	fff70793          	add	a5,a4,-1
   111c2:	00279693          	sll	a3,a5,0x2
   111c6:	96be                	add	a3,a3,a5
   111c8:	0692                	sll	a3,a3,0x4
   111ca:	b4c18793          	add	a5,gp,-1204 # 143c8 <input_strings>
   111ce:	97b6                	add	a5,a5,a3
   111d0:	b241a603          	lw	a2,-1244(gp) # 143a0 <bomb_id>
   111d4:	cd15                	beqz	a0,11210 <send_msg+0x60>
   111d6:	66c9                	lui	a3,0x12
   111d8:	e2468693          	add	a3,a3,-476 # 11e24 <_IO_stdin_used+0x348>
   111dc:	6589                	lui	a1,0x2
   111de:	00b10433          	add	s0,sp,a1
   111e2:	65c9                	lui	a1,0x12
   111e4:	e3858593          	add	a1,a1,-456 # 11e38 <_IO_stdin_used+0x35c>
   111e8:	8522                	mv	a0,s0
   111ea:	837ff0ef          	jal	10a20 <sprintf@plt>
   111ee:	870a                	mv	a4,sp
   111f0:	4681                	li	a3,0
   111f2:	8622                	mv	a2,s0
   111f4:	8fc18593          	add	a1,gp,-1796 # 14178 <user_password>
   111f8:	91418513          	add	a0,gp,-1772 # 14190 <userid>
   111fc:	067000ef          	jal	11a62 <driver_post>
   11200:	00054c63          	bltz	a0,11218 <send_msg+0x68>
   11204:	6291                	lui	t0,0x4
   11206:	9116                	add	sp,sp,t0
   11208:	40b2                	lw	ra,12(sp)
   1120a:	4422                	lw	s0,8(sp)
   1120c:	0141                	add	sp,sp,16
   1120e:	8082                	ret
   11210:	66c9                	lui	a3,0x12
   11212:	e2c68693          	add	a3,a3,-468 # 11e2c <_IO_stdin_used+0x350>
   11216:	b7d9                	j	111dc <send_msg+0x2c>
   11218:	850a                	mv	a0,sp
   1121a:	fc6ff0ef          	jal	109e0 <puts@plt>
   1121e:	4501                	li	a0,0
   11220:	fe0ff0ef          	jal	10a00 <exit@plt>

00011224 <explode_bomb>:
   11224:	1141                	add	sp,sp,-16
   11226:	c606                	sw	ra,12(sp)
   11228:	c422                	sw	s0,8(sp)
   1122a:	c226                	sw	s1,4(sp)
   1122c:	6549                	lui	a0,0x12
   1122e:	e4450513          	add	a0,a0,-444 # 11e44 <_IO_stdin_used+0x368>
   11232:	f6eff0ef          	jal	109a0 <printf@plt>
   11236:	6449                	lui	s0,0x12
   11238:	e7c40513          	add	a0,s0,-388 # 11e7c <_IO_stdin_used+0x3a0>
   1123c:	f64ff0ef          	jal	109a0 <printf@plt>
   11240:	6549                	lui	a0,0x12
   11242:	eb450513          	add	a0,a0,-332 # 11eb4 <_IO_stdin_used+0x3d8>
   11246:	f5aff0ef          	jal	109a0 <printf@plt>
   1124a:	6549                	lui	a0,0x12
   1124c:	eec50513          	add	a0,a0,-276 # 11eec <_IO_stdin_used+0x410>
   11250:	f50ff0ef          	jal	109a0 <printf@plt>
   11254:	6549                	lui	a0,0x12
   11256:	f2450513          	add	a0,a0,-220 # 11f24 <_IO_stdin_used+0x448>
   1125a:	f46ff0ef          	jal	109a0 <printf@plt>
   1125e:	64c9                	lui	s1,0x12
   11260:	f5c48513          	add	a0,s1,-164 # 11f5c <_IO_stdin_used+0x480>
   11264:	f3cff0ef          	jal	109a0 <printf@plt>
   11268:	f5c48513          	add	a0,s1,-164
   1126c:	f34ff0ef          	jal	109a0 <printf@plt>
   11270:	6549                	lui	a0,0x12
   11272:	f9450513          	add	a0,a0,-108 # 11f94 <_IO_stdin_used+0x4b8>
   11276:	f2aff0ef          	jal	109a0 <printf@plt>
   1127a:	e7c40513          	add	a0,s0,-388
   1127e:	f62ff0ef          	jal	109e0 <puts@plt>
   11282:	6549                	lui	a0,0x12
   11284:	fcc50513          	add	a0,a0,-52 # 11fcc <_IO_stdin_used+0x4f0>
   11288:	f58ff0ef          	jal	109e0 <puts@plt>
   1128c:	4501                	li	a0,0
   1128e:	370d                	jal	111b0 <send_msg>
   11290:	6549                	lui	a0,0x12
   11292:	fe450513          	add	a0,a0,-28 # 11fe4 <_IO_stdin_used+0x508>
   11296:	f4aff0ef          	jal	109e0 <puts@plt>
   1129a:	4521                	li	a0,8
   1129c:	f64ff0ef          	jal	10a00 <exit@plt>

000112a0 <read_six_things>:
   112a0:	1141                	add	sp,sp,-16
   112a2:	c606                	sw	ra,12(sp)
   112a4:	862e                	mv	a2,a1
   112a6:	01458893          	add	a7,a1,20
   112aa:	01058813          	add	a6,a1,16
   112ae:	00c58793          	add	a5,a1,12
   112b2:	00858713          	add	a4,a1,8
   112b6:	00458693          	add	a3,a1,4
   112ba:	65c9                	lui	a1,0x12
   112bc:	00c58593          	add	a1,a1,12 # 1200c <_IO_stdin_used+0x530>
   112c0:	ed0ff0ef          	jal	10990 <__isoc23_sscanf@plt>
   112c4:	4795                	li	a5,5
   112c6:	00a7d563          	bge	a5,a0,112d0 <read_six_things+0x30>
   112ca:	40b2                	lw	ra,12(sp)
   112cc:	0141                	add	sp,sp,16
   112ce:	8082                	ret
   112d0:	3f91                	jal	11224 <explode_bomb>

000112d2 <read_line>:
   112d2:	1141                	add	sp,sp,-16
   112d4:	c606                	sw	ra,12(sp)
   112d6:	c422                	sw	s0,8(sp)
   112d8:	c226                	sw	s1,4(sp)
   112da:	3579                	jal	11168 <skip>
   112dc:	c521                	beqz	a0,11324 <read_line+0x52>
   112de:	b2c1a403          	lw	s0,-1236(gp) # 143a8 <num_input_strings>
   112e2:	00241793          	sll	a5,s0,0x2
   112e6:	97a2                	add	a5,a5,s0
   112e8:	0792                	sll	a5,a5,0x4
   112ea:	b4c18493          	add	s1,gp,-1204 # 143c8 <input_strings>
   112ee:	94be                	add	s1,s1,a5
   112f0:	8526                	mv	a0,s1
   112f2:	fdeff0ef          	jal	10ad0 <strlen@plt>
   112f6:	04e00793          	li	a5,78
   112fa:	06a7ca63          	blt	a5,a0,1136e <read_line+0x9c>
   112fe:	00241713          	sll	a4,s0,0x2
   11302:	9722                	add	a4,a4,s0
   11304:	0712                	sll	a4,a4,0x4
   11306:	b4c18793          	add	a5,gp,-1204 # 143c8 <input_strings>
   1130a:	97ba                	add	a5,a5,a4
   1130c:	953e                	add	a0,a0,a5
   1130e:	fe050fa3          	sb	zero,-1(a0)
   11312:	0405                	add	s0,s0,1
   11314:	b281a623          	sw	s0,-1236(gp) # 143a8 <num_input_strings>
   11318:	8526                	mv	a0,s1
   1131a:	40b2                	lw	ra,12(sp)
   1131c:	4422                	lw	s0,8(sp)
   1131e:	4492                	lw	s1,4(sp)
   11320:	0141                	add	sp,sp,16
   11322:	8082                	ret
   11324:	b281a703          	lw	a4,-1240(gp) # 143a4 <infile>
   11328:	b441a783          	lw	a5,-1212(gp) # 143c0 <stdin@GLIBC_2.33>
   1132c:	00f70b63          	beq	a4,a5,11342 <read_line+0x70>
   11330:	6549                	lui	a0,0x12
   11332:	04050513          	add	a0,a0,64 # 12040 <_IO_stdin_used+0x564>
   11336:	f6aff0ef          	jal	10aa0 <getenv@plt>
   1133a:	cd01                	beqz	a0,11352 <read_line+0x80>
   1133c:	4501                	li	a0,0
   1133e:	ec2ff0ef          	jal	10a00 <exit@plt>
   11342:	6549                	lui	a0,0x12
   11344:	02050513          	add	a0,a0,32 # 12020 <_IO_stdin_used+0x544>
   11348:	e98ff0ef          	jal	109e0 <puts@plt>
   1134c:	4521                	li	a0,8
   1134e:	eb2ff0ef          	jal	10a00 <exit@plt>
   11352:	b441a703          	lw	a4,-1212(gp) # 143c0 <stdin@GLIBC_2.33>
   11356:	b2e1a423          	sw	a4,-1240(gp) # 143a4 <infile>
   1135a:	3539                	jal	11168 <skip>
   1135c:	f149                	bnez	a0,112de <read_line+0xc>
   1135e:	6549                	lui	a0,0x12
   11360:	02050513          	add	a0,a0,32 # 12020 <_IO_stdin_used+0x544>
   11364:	e7cff0ef          	jal	109e0 <puts@plt>
   11368:	4501                	li	a0,0
   1136a:	e96ff0ef          	jal	10a00 <exit@plt>
   1136e:	6549                	lui	a0,0x12
   11370:	04c50513          	add	a0,a0,76 # 1204c <_IO_stdin_used+0x570>
   11374:	e6cff0ef          	jal	109e0 <puts@plt>
   11378:	b2c1a783          	lw	a5,-1236(gp) # 143a8 <num_input_strings>
   1137c:	00178693          	add	a3,a5,1
   11380:	b2d1a623          	sw	a3,-1236(gp) # 143a8 <num_input_strings>
   11384:	05000713          	li	a4,80
   11388:	02e78733          	mul	a4,a5,a4
   1138c:	b4c18793          	add	a5,gp,-1204 # 143c8 <input_strings>
   11390:	97ba                	add	a5,a5,a4
   11392:	6749                	lui	a4,0x12
   11394:	06870713          	add	a4,a4,104 # 12068 <_IO_stdin_used+0x58c>
   11398:	430c                	lw	a1,0(a4)
   1139a:	4350                	lw	a2,4(a4)
   1139c:	4714                	lw	a3,8(a4)
   1139e:	c38c                	sw	a1,0(a5)
   113a0:	c3d0                	sw	a2,4(a5)
   113a2:	c794                	sw	a3,8(a5)
   113a4:	4758                	lw	a4,12(a4)
   113a6:	c7d8                	sw	a4,12(a5)
   113a8:	3db5                	jal	11224 <explode_bomb>

000113aa <phase_defused>:
   113aa:	7159                	add	sp,sp,-112
   113ac:	d686                	sw	ra,108(sp)
   113ae:	4505                	li	a0,1
   113b0:	3501                	jal	111b0 <send_msg>
   113b2:	b2c1a703          	lw	a4,-1236(gp) # 143a8 <num_input_strings>
   113b6:	4799                	li	a5,6
   113b8:	00f70563          	beq	a4,a5,113c2 <phase_defused+0x18>
   113bc:	50b6                	lw	ra,108(sp)
   113be:	6165                	add	sp,sp,112
   113c0:	8082                	ret
   113c2:	0070                	add	a2,sp,12
   113c4:	0818                	add	a4,sp,16
   113c6:	86b2                	mv	a3,a2
   113c8:	65c9                	lui	a1,0x12
   113ca:	07858593          	add	a1,a1,120 # 12078 <_IO_stdin_used+0x59c>
   # Marker
   113ce:	b4c18513          	add	a0,gp,-1204 # 143c8 <input_strings>
   113d2:	dbeff0ef          	jal	10990 <__isoc23_sscanf@plt>
   113d6:	478d                	li	a5,3
   113d8:	00f50d63          	beq	a0,a5,113f2 <phase_defused+0x48>
   113dc:	6549                	lui	a0,0x12
   113de:	0f050513          	add	a0,a0,240 # 120f0 <_IO_stdin_used+0x614>
   113e2:	dfeff0ef          	jal	109e0 <puts@plt>
   113e6:	6549                	lui	a0,0x12
   113e8:	13450513          	add	a0,a0,308 # 12134 <_IO_stdin_used+0x658>
   113ec:	df4ff0ef          	jal	109e0 <puts@plt>
   113f0:	b7f1                	j	113bc <phase_defused+0x12>
   113f2:	65c9                	lui	a1,0x12
   113f4:	08458593          	add	a1,a1,132 # 12084 <_IO_stdin_used+0x5a8>
   113f8:	0808                	add	a0,sp,16
   113fa:	f26ff0ef          	jal	10b20 <strcmp@plt>
   113fe:	fd79                	bnez	a0,113dc <phase_defused+0x32>
   11400:	6549                	lui	a0,0x12
   11402:	09050513          	add	a0,a0,144 # 12090 <_IO_stdin_used+0x5b4>
   11406:	ddaff0ef          	jal	109e0 <puts@plt>
   1140a:	6549                	lui	a0,0x12
   1140c:	0b850513          	add	a0,a0,184 # 120b8 <_IO_stdin_used+0x5dc>
   11410:	dd0ff0ef          	jal	109e0 <puts@plt>
   11414:	3ed1                	jal	10fe8 <secret_phase>
   11416:	b7d9                	j	113dc <phase_defused+0x32>

00011418 <sigalrm_handler>:
   11418:	1141                	add	sp,sp,-16
   1141a:	c606                	sw	ra,12(sp)
   1141c:	4601                	li	a2,0
   1141e:	65c9                	lui	a1,0x12
   11420:	19858593          	add	a1,a1,408 # 12198 <_IO_stdin_used+0x6bc>
   11424:	b3c1a503          	lw	a0,-1220(gp) # 143b8 <stderr@GLIBC_2.33>
   11428:	e68ff0ef          	jal	10a90 <fprintf@plt>
   1142c:	4505                	li	a0,1
   1142e:	dd2ff0ef          	jal	10a00 <exit@plt>

00011432 <rio_readlineb>:
   11432:	7179                	add	sp,sp,-48
   11434:	d606                	sw	ra,44(sp)
   11436:	cc52                	sw	s4,24(sp)
   11438:	ca56                	sw	s5,20(sp)
   1143a:	8a2e                	mv	s4,a1
   1143c:	4785                	li	a5,1
   1143e:	08c7ff63          	bgeu	a5,a2,114dc <rio_readlineb+0xaa>
   11442:	d422                	sw	s0,40(sp)
   11444:	d226                	sw	s1,36(sp)
   11446:	d04a                	sw	s2,32(sp)
   11448:	ce4e                	sw	s3,28(sp)
   1144a:	c85a                	sw	s6,16(sp)
   1144c:	c65e                	sw	s7,12(sp)
   1144e:	842a                	mv	s0,a0
   11450:	167d                	add	a2,a2,-1
   11452:	00c58b33          	add	s6,a1,a2
   11456:	8abe                	mv	s5,a5
   11458:	00c50493          	add	s1,a0,12
   1145c:	6909                	lui	s2,0x2
   1145e:	4991                	li	s3,4
   11460:	4ba9                	li	s7,10
   11462:	a83d                	j	114a0 <rio_readlineb+0x6e>
   11464:	e1cff0ef          	jal	10a80 <__errno_location@plt>
   11468:	411c                	lw	a5,0(a0)
   1146a:	05379d63          	bne	a5,s3,114c4 <rio_readlineb+0x92>
   1146e:	864a                	mv	a2,s2
   11470:	85a6                	mv	a1,s1
   11472:	4008                	lw	a0,0(s0)
   11474:	cecff0ef          	jal	10960 <read@plt>
   11478:	c048                	sw	a0,4(s0)
   1147a:	fe0545e3          	bltz	a0,11464 <rio_readlineb+0x32>
   1147e:	c521                	beqz	a0,114c6 <rio_readlineb+0x94>
   11480:	c404                	sw	s1,8(s0)
   11482:	441c                	lw	a5,8(s0)
   11484:	0007c703          	lbu	a4,0(a5)
   11488:	0785                	add	a5,a5,1
   1148a:	c41c                	sw	a5,8(s0)
   1148c:	157d                	add	a0,a0,-1
   1148e:	c048                	sw	a0,4(s0)
   11490:	0a05                	add	s4,s4,1
   11492:	feea0fa3          	sb	a4,-1(s4)
   11496:	01770963          	beq	a4,s7,114a8 <rio_readlineb+0x76>
   1149a:	0a85                	add	s5,s5,1
   1149c:	056a0263          	beq	s4,s6,114e0 <rio_readlineb+0xae>
   114a0:	4048                	lw	a0,4(s0)
   114a2:	fca056e3          	blez	a0,1146e <rio_readlineb+0x3c>
   114a6:	bff1                	j	11482 <rio_readlineb+0x50>
   114a8:	5422                	lw	s0,40(sp)
   114aa:	5492                	lw	s1,36(sp)
   114ac:	5902                	lw	s2,32(sp)
   114ae:	49f2                	lw	s3,28(sp)
   114b0:	4b42                	lw	s6,16(sp)
   114b2:	4bb2                	lw	s7,12(sp)
   114b4:	000a0023          	sb	zero,0(s4)
   114b8:	8556                	mv	a0,s5
   114ba:	50b2                	lw	ra,44(sp)
   114bc:	4a62                	lw	s4,24(sp)
   114be:	4ad2                	lw	s5,20(sp)
   114c0:	6145                	add	sp,sp,48
   114c2:	8082                	ret
   114c4:	557d                	li	a0,-1
   114c6:	e505                	bnez	a0,114ee <rio_readlineb+0xbc>
   114c8:	4785                	li	a5,1
   114ca:	02fa8a63          	beq	s5,a5,114fe <rio_readlineb+0xcc>
   114ce:	5422                	lw	s0,40(sp)
   114d0:	5492                	lw	s1,36(sp)
   114d2:	5902                	lw	s2,32(sp)
   114d4:	49f2                	lw	s3,28(sp)
   114d6:	4b42                	lw	s6,16(sp)
   114d8:	4bb2                	lw	s7,12(sp)
   114da:	bfe9                	j	114b4 <rio_readlineb+0x82>
   114dc:	4a85                	li	s5,1
   114de:	bfd9                	j	114b4 <rio_readlineb+0x82>
   114e0:	5422                	lw	s0,40(sp)
   114e2:	5492                	lw	s1,36(sp)
   114e4:	5902                	lw	s2,32(sp)
   114e6:	49f2                	lw	s3,28(sp)
   114e8:	4b42                	lw	s6,16(sp)
   114ea:	4bb2                	lw	s7,12(sp)
   114ec:	b7e1                	j	114b4 <rio_readlineb+0x82>
   114ee:	5afd                	li	s5,-1
   114f0:	5422                	lw	s0,40(sp)
   114f2:	5492                	lw	s1,36(sp)
   114f4:	5902                	lw	s2,32(sp)
   114f6:	49f2                	lw	s3,28(sp)
   114f8:	4b42                	lw	s6,16(sp)
   114fa:	4bb2                	lw	s7,12(sp)
   114fc:	bf75                	j	114b8 <rio_readlineb+0x86>
   114fe:	8aaa                	mv	s5,a0
   11500:	5422                	lw	s0,40(sp)
   11502:	5492                	lw	s1,36(sp)
   11504:	5902                	lw	s2,32(sp)
   11506:	49f2                	lw	s3,28(sp)
   11508:	4b42                	lw	s6,16(sp)
   1150a:	4bb2                	lw	s7,12(sp)
   1150c:	b775                	j	114b8 <rio_readlineb+0x86>

0001150e <submitr>:
   1150e:	7119                	add	sp,sp,-128
   11510:	de86                	sw	ra,124(sp)
   11512:	dca2                	sw	s0,120(sp)
   11514:	daa6                	sw	s1,116(sp)
   11516:	d8ca                	sw	s2,112(sp)
   11518:	d6ce                	sw	s3,108(sp)
   1151a:	d4d2                	sw	s4,104(sp)
   1151c:	d2d6                	sw	s5,100(sp)
   1151e:	d0da                	sw	s6,96(sp)
   11520:	cede                	sw	s7,92(sp)
   11522:	cce2                	sw	s8,88(sp)
   11524:	cae6                	sw	s9,84(sp)
   11526:	c8ea                	sw	s10,80(sp)
   11528:	c6ee                	sw	s11,76(sp)
   1152a:	72d9                	lui	t0,0xffff6
   1152c:	9116                	add	sp,sp,t0
   1152e:	84aa                	mv	s1,a0
   11530:	842e                	mv	s0,a1
   11532:	8c32                	mv	s8,a2
   11534:	8cb6                	mv	s9,a3
   11536:	c63a                	sw	a4,12(sp)
   11538:	8d3e                	mv	s10,a5
   1153a:	8942                	mv	s2,a6
   1153c:	8dc6                	mv	s11,a7
   1153e:	6789                	lui	a5,0x2
   11540:	04078793          	add	a5,a5,64 # 2040 <_PROCEDURE_LINKAGE_TABLE_-0xe8f0>
   11544:	978a                	add	a5,a5,sp
   11546:	fe07a023          	sw	zero,-32(a5)
   1154a:	4601                	li	a2,0
   1154c:	4585                	li	a1,1
   1154e:	4509                	li	a0,2
   11550:	ce0ff0ef          	jal	10a30 <socket@plt>
   11554:	0e054c63          	bltz	a0,1164c <submitr+0x13e>
   11558:	89aa                	mv	s3,a0
   1155a:	8526                	mv	a0,s1
   1155c:	d54ff0ef          	jal	10ab0 <gethostbyname@plt>
   11560:	10050063          	beqz	a0,11660 <submitr+0x152>
   11564:	64a9                	lui	s1,0xa
   11566:	03248793          	add	a5,s1,50 # a032 <_PROCEDURE_LINKAGE_TABLE_-0x68fe>
   1156a:	978a                	add	a5,a5,sp
   1156c:	02248713          	add	a4,s1,34
   11570:	0814                	add	a3,sp,16
   11572:	9736                	add	a4,a4,a3
   11574:	00071023          	sh	zero,0(a4)
   11578:	00079123          	sh	zero,2(a5)
   1157c:	00079223          	sh	zero,4(a5)
   11580:	00079323          	sh	zero,6(a5)
   11584:	00079423          	sh	zero,8(a5)
   11588:	00079523          	sh	zero,10(a5)
   1158c:	00079623          	sh	zero,12(a5)
   11590:	4789                	li	a5,2
   11592:	02048713          	add	a4,s1,32
   11596:	9736                	add	a4,a4,a3
   11598:	00f71023          	sh	a5,0(a4)
   1159c:	491c                	lw	a5,16(a0)
   1159e:	4550                	lw	a2,12(a0)
   115a0:	438c                	lw	a1,0(a5)
   115a2:	03448793          	add	a5,s1,52
   115a6:	00278533          	add	a0,a5,sp
   115aa:	d46ff0ef          	jal	10af0 <memmove@plt>
   115ae:	01041713          	sll	a4,s0,0x10
   115b2:	01875793          	srl	a5,a4,0x18
   115b6:	0ff47593          	zext.b	a1,s0
   115ba:	05a2                	sll	a1,a1,0x8
   115bc:	8ddd                	or	a1,a1,a5
   115be:	02248793          	add	a5,s1,34
   115c2:	0818                	add	a4,sp,16
   115c4:	97ba                	add	a5,a5,a4
   115c6:	00b79023          	sh	a1,0(a5)
   115ca:	4641                	li	a2,16
   115cc:	02048793          	add	a5,s1,32
   115d0:	97b2                	add	a5,a5,a2
   115d2:	002785b3          	add	a1,a5,sp
   115d6:	854e                	mv	a0,s3
   115d8:	d38ff0ef          	jal	10b10 <connect@plt>
   115dc:	08054f63          	bltz	a0,1167a <submitr+0x16c>
   115e0:	854a                	mv	a0,s2
   115e2:	ceeff0ef          	jal	10ad0 <strlen@plt>
   115e6:	84aa                	mv	s1,a0
   115e8:	8562                	mv	a0,s8
   115ea:	ce6ff0ef          	jal	10ad0 <strlen@plt>
   115ee:	842a                	mv	s0,a0
   115f0:	8566                	mv	a0,s9
   115f2:	cdeff0ef          	jal	10ad0 <strlen@plt>
   115f6:	8a2a                	mv	s4,a0
   115f8:	856a                	mv	a0,s10
   115fa:	cd6ff0ef          	jal	10ad0 <strlen@plt>
   115fe:	9452                	add	s0,s0,s4
   11600:	08040413          	add	s0,s0,128
   11604:	942a                	add	s0,s0,a0
   11606:	00149793          	sll	a5,s1,0x1
   1160a:	97a6                	add	a5,a5,s1
   1160c:	943e                	add	s0,s0,a5
   1160e:	6789                	lui	a5,0x2
   11610:	0887e263          	bltu	a5,s0,11694 <submitr+0x186>
   11614:	6609                	lui	a2,0x2
   11616:	4581                	li	a1,0
   11618:	6491                	lui	s1,0x4
   1161a:	02448793          	add	a5,s1,36 # 4024 <_PROCEDURE_LINKAGE_TABLE_-0xc90c>
   1161e:	00278533          	add	a0,a5,sp
   11622:	c4eff0ef          	jal	10a70 <memset@plt>
   11626:	854a                	mv	a0,s2
   11628:	ca8ff0ef          	jal	10ad0 <strlen@plt>
   1162c:	10050963          	beqz	a0,1173e <submitr+0x230>
   11630:	844a                	mv	s0,s2
   11632:	02448793          	add	a5,s1,36
   11636:	002784b3          	add	s1,a5,sp
   1163a:	4a3d                	li	s4,15
   1163c:	05f00b13          	li	s6,95
   11640:	4be5                	li	s7,25
   11642:	6ac1                	lui	s5,0x10
   11644:	fd9a8a93          	add	s5,s5,-39 # ffd9 <_PROCEDURE_LINKAGE_TABLE_-0x957>
   11648:	992a                	add	s2,s2,a0
   1164a:	a895                	j	116be <submitr+0x1b0>
   1164c:	02600613          	li	a2,38
   11650:	65c9                	lui	a1,0x12
   11652:	1bc58593          	add	a1,a1,444 # 121bc <_IO_stdin_used+0x6e0>
   11656:	856e                	mv	a0,s11
   11658:	c68ff0ef          	jal	10ac0 <memcpy@plt>
   1165c:	557d                	li	a0,-1
   1165e:	a461                	j	118e6 <submitr+0x3d8>
   11660:	02f00613          	li	a2,47
   11664:	65c9                	lui	a1,0x12
   11666:	1e458593          	add	a1,a1,484 # 121e4 <_IO_stdin_used+0x708>
   1166a:	856e                	mv	a0,s11
   1166c:	c54ff0ef          	jal	10ac0 <memcpy@plt>
   11670:	854e                	mv	a0,s3
   11672:	b5eff0ef          	jal	109d0 <close@plt>
   11676:	557d                	li	a0,-1
   11678:	a4bd                	j	118e6 <submitr+0x3d8>
   1167a:	02700613          	li	a2,39
   1167e:	65c9                	lui	a1,0x12
   11680:	21458593          	add	a1,a1,532 # 12214 <_IO_stdin_used+0x738>
   11684:	856e                	mv	a0,s11
   11686:	c3aff0ef          	jal	10ac0 <memcpy@plt>
   1168a:	854e                	mv	a0,s3
   1168c:	b44ff0ef          	jal	109d0 <close@plt>
   11690:	557d                	li	a0,-1
   11692:	ac91                	j	118e6 <submitr+0x3d8>
   11694:	03800613          	li	a2,56
   11698:	65c9                	lui	a1,0x12
   1169a:	23c58593          	add	a1,a1,572 # 1223c <_IO_stdin_used+0x760>
   1169e:	856e                	mv	a0,s11
   116a0:	c20ff0ef          	jal	10ac0 <memcpy@plt>
   116a4:	854e                	mv	a0,s3
   116a6:	b2aff0ef          	jal	109d0 <close@plt>
   116aa:	557d                	li	a0,-1
   116ac:	ac2d                	j	118e6 <submitr+0x3d8>
   116ae:	07661663          	bne	a2,s6,1171a <submitr+0x20c>
   116b2:	00c48023          	sb	a2,0(s1)
   116b6:	0485                	add	s1,s1,1
   116b8:	0405                	add	s0,s0,1
   116ba:	09240263          	beq	s0,s2,1173e <submitr+0x230>
   116be:	00044603          	lbu	a2,0(s0)
   116c2:	fd660793          	add	a5,a2,-42 # 1fd6 <_PROCEDURE_LINKAGE_TABLE_-0xe95a>
   116c6:	0ff7f793          	zext.b	a5,a5
   116ca:	fefa62e3          	bltu	s4,a5,116ae <submitr+0x1a0>
   116ce:	00fad7b3          	srl	a5,s5,a5
   116d2:	8b85                	and	a5,a5,1
   116d4:	fff9                	bnez	a5,116b2 <submitr+0x1a4>
   116d6:	fa160793          	add	a5,a2,-95
   116da:	dfe1                	beqz	a5,116b2 <submitr+0x1a4>
   116dc:	fe060793          	add	a5,a2,-32
   116e0:	0ff7f793          	zext.b	a5,a5
   116e4:	0607b793          	sltiu	a5,a5,96
   116e8:	e789                	bnez	a5,116f2 <submitr+0x1e4>
   116ea:	ff760793          	add	a5,a2,-9
   116ee:	22079a63          	bnez	a5,11922 <submitr+0x414>
   116f2:	65c9                	lui	a1,0x12
   116f4:	27458593          	add	a1,a1,628 # 12274 <_IO_stdin_used+0x798>
   116f8:	0828                	add	a0,sp,24
   116fa:	b26ff0ef          	jal	10a20 <sprintf@plt>
   116fe:	01814703          	lbu	a4,24(sp)
   11702:	00e48023          	sb	a4,0(s1)
   11706:	01914703          	lbu	a4,25(sp)
   1170a:	00e480a3          	sb	a4,1(s1)
   1170e:	01a14783          	lbu	a5,26(sp)
   11712:	00f48123          	sb	a5,2(s1)
   11716:	048d                	add	s1,s1,3
   11718:	b745                	j	116b8 <submitr+0x1aa>
   1171a:	fdf67793          	and	a5,a2,-33
   1171e:	fbf78793          	add	a5,a5,-65 # 1fbf <_PROCEDURE_LINKAGE_TABLE_-0xe971>
   11722:	0ff7f793          	zext.b	a5,a5
   11726:	f8fbf6e3          	bgeu	s7,a5,116b2 <submitr+0x1a4>
   1172a:	02000793          	li	a5,32
   1172e:	faf617e3          	bne	a2,a5,116dc <submitr+0x1ce>
   11732:	02b00793          	li	a5,43
   11736:	00f48023          	sb	a5,0(s1)
   1173a:	0485                	add	s1,s1,1
   1173c:	bfb5                	j	116b8 <submitr+0x1aa>
   1173e:	6499                	lui	s1,0x6
   11740:	02448793          	add	a5,s1,36 # 6024 <_PROCEDURE_LINKAGE_TABLE_-0xa90c>
   11744:	00278433          	add	s0,a5,sp
   11748:	6791                	lui	a5,0x4
   1174a:	02478793          	add	a5,a5,36 # 4024 <_PROCEDURE_LINKAGE_TABLE_-0xc90c>
   1174e:	00278833          	add	a6,a5,sp
   11752:	87ea                	mv	a5,s10
   11754:	4732                	lw	a4,12(sp)
   11756:	86e6                	mv	a3,s9
   11758:	8662                	mv	a2,s8
   1175a:	65c9                	lui	a1,0x12
   1175c:	27c58593          	add	a1,a1,636 # 1227c <_IO_stdin_used+0x7a0>
   11760:	8522                	mv	a0,s0
   11762:	abeff0ef          	jal	10a20 <sprintf@plt>
   11766:	8522                	mv	a0,s0
   11768:	b68ff0ef          	jal	10ad0 <strlen@plt>
   1176c:	842a                	mv	s0,a0
   1176e:	c51d                	beqz	a0,1179c <submitr+0x28e>
   11770:	02448793          	add	a5,s1,36
   11774:	002784b3          	add	s1,a5,sp
   11778:	4911                	li	s2,4
   1177a:	a031                	j	11786 <submitr+0x278>
   1177c:	b04ff0ef          	jal	10a80 <__errno_location@plt>
   11780:	411c                	lw	a5,0(a0)
   11782:	0d279863          	bne	a5,s2,11852 <submitr+0x344>
   11786:	8622                	mv	a2,s0
   11788:	85a6                	mv	a1,s1
   1178a:	854e                	mv	a0,s3
   1178c:	a24ff0ef          	jal	109b0 <write@plt>
   11790:	fea056e3          	blez	a0,1177c <submitr+0x26e>
   11794:	8c09                	sub	s0,s0,a0
   11796:	c019                	beqz	s0,1179c <submitr+0x28e>
   11798:	94aa                	add	s1,s1,a0
   1179a:	b7f5                	j	11786 <submitr+0x278>
   1179c:	6721                	lui	a4,0x8
   1179e:	04070793          	add	a5,a4,64 # 8040 <_PROCEDURE_LINKAGE_TABLE_-0x88f0>
   117a2:	978a                	add	a5,a5,sp
   117a4:	ff37a223          	sw	s3,-28(a5)
   117a8:	fe07a423          	sw	zero,-24(a5)
   117ac:	02470713          	add	a4,a4,36
   117b0:	00270533          	add	a0,a4,sp
   117b4:	00c50713          	add	a4,a0,12
   117b8:	fee7a623          	sw	a4,-20(a5)
   117bc:	6609                	lui	a2,0x2
   117be:	6799                	lui	a5,0x6
   117c0:	02478793          	add	a5,a5,36 # 6024 <_PROCEDURE_LINKAGE_TABLE_-0xa90c>
   117c4:	002785b3          	add	a1,a5,sp
   117c8:	31ad                	jal	11432 <rio_readlineb>
   117ca:	0aa05163          	blez	a0,1186c <submitr+0x35e>
   117ce:	1018                	add	a4,sp,32
   117d0:	6409                	lui	s0,0x2
   117d2:	02040793          	add	a5,s0,32 # 2020 <_PROCEDURE_LINKAGE_TABLE_-0xe910>
   117d6:	002786b3          	add	a3,a5,sp
   117da:	02440793          	add	a5,s0,36
   117de:	00278633          	add	a2,a5,sp
   117e2:	65c9                	lui	a1,0x12
   117e4:	33858593          	add	a1,a1,824 # 12338 <_IO_stdin_used+0x85c>
   117e8:	6499                	lui	s1,0x6
   117ea:	02448793          	add	a5,s1,36 # 6024 <_PROCEDURE_LINKAGE_TABLE_-0xa90c>
   117ee:	00278533          	add	a0,a5,sp
   117f2:	99eff0ef          	jal	10990 <__isoc23_sscanf@plt>
   117f6:	04040793          	add	a5,s0,64
   117fa:	978a                	add	a5,a5,sp
   117fc:	fe07a603          	lw	a2,-32(a5)
   11800:	0c800793          	li	a5,200
   11804:	08f61163          	bne	a2,a5,11886 <submitr+0x378>
   11808:	02448793          	add	a5,s1,36
   1180c:	00278433          	add	s0,a5,sp
   11810:	6949                	lui	s2,0x12
   11812:	3b090913          	add	s2,s2,944 # 123b0 <_IO_stdin_used+0x8d4>
   11816:	67a1                	lui	a5,0x8
   11818:	02478793          	add	a5,a5,36 # 8024 <_PROCEDURE_LINKAGE_TABLE_-0x890c>
   1181c:	002784b3          	add	s1,a5,sp
   11820:	6a09                	lui	s4,0x2
   11822:	85ca                	mv	a1,s2
   11824:	8522                	mv	a0,s0
   11826:	afaff0ef          	jal	10b20 <strcmp@plt>
   1182a:	c935                	beqz	a0,1189e <submitr+0x390>
   1182c:	8652                	mv	a2,s4
   1182e:	85a2                	mv	a1,s0
   11830:	8526                	mv	a0,s1
   11832:	3101                	jal	11432 <rio_readlineb>
   11834:	fea047e3          	bgtz	a0,11822 <submitr+0x314>
   11838:	03100613          	li	a2,49
   1183c:	65c9                	lui	a1,0x12
   1183e:	37c58593          	add	a1,a1,892 # 1237c <_IO_stdin_used+0x8a0>
   11842:	856e                	mv	a0,s11
   11844:	a7cff0ef          	jal	10ac0 <memcpy@plt>
   11848:	854e                	mv	a0,s3
   1184a:	986ff0ef          	jal	109d0 <close@plt>
   1184e:	557d                	li	a0,-1
   11850:	a859                	j	118e6 <submitr+0x3d8>
   11852:	02c00613          	li	a2,44
   11856:	65c9                	lui	a1,0x12
   11858:	2d458593          	add	a1,a1,724 # 122d4 <_IO_stdin_used+0x7f8>
   1185c:	856e                	mv	a0,s11
   1185e:	a62ff0ef          	jal	10ac0 <memcpy@plt>
   11862:	854e                	mv	a0,s3
   11864:	96cff0ef          	jal	109d0 <close@plt>
   11868:	557d                	li	a0,-1
   1186a:	a8b5                	j	118e6 <submitr+0x3d8>
   1186c:	03600613          	li	a2,54
   11870:	65c9                	lui	a1,0x12
   11872:	30058593          	add	a1,a1,768 # 12300 <_IO_stdin_used+0x824>
   11876:	856e                	mv	a0,s11
   11878:	a48ff0ef          	jal	10ac0 <memcpy@plt>
   1187c:	854e                	mv	a0,s3
   1187e:	952ff0ef          	jal	109d0 <close@plt>
   11882:	557d                	li	a0,-1
   11884:	a08d                	j	118e6 <submitr+0x3d8>
   11886:	1014                	add	a3,sp,32
   11888:	65c9                	lui	a1,0x12
   1188a:	34c58593          	add	a1,a1,844 # 1234c <_IO_stdin_used+0x870>
   1188e:	856e                	mv	a0,s11
   11890:	990ff0ef          	jal	10a20 <sprintf@plt>
   11894:	854e                	mv	a0,s3
   11896:	93aff0ef          	jal	109d0 <close@plt>
   1189a:	557d                	li	a0,-1
   1189c:	a0a9                	j	118e6 <submitr+0x3d8>
   1189e:	6609                	lui	a2,0x2
   118a0:	6799                	lui	a5,0x6
   118a2:	02478793          	add	a5,a5,36 # 6024 <_PROCEDURE_LINKAGE_TABLE_-0xa90c>
   118a6:	002785b3          	add	a1,a5,sp
   118aa:	67a1                	lui	a5,0x8
   118ac:	02478793          	add	a5,a5,36 # 8024 <_PROCEDURE_LINKAGE_TABLE_-0x890c>
   118b0:	00278533          	add	a0,a5,sp
   118b4:	3ebd                	jal	11432 <rio_readlineb>
   118b6:	04a05963          	blez	a0,11908 <submitr+0x3fa>
   118ba:	6799                	lui	a5,0x6
   118bc:	02478793          	add	a5,a5,36 # 6024 <_PROCEDURE_LINKAGE_TABLE_-0xa90c>
   118c0:	002785b3          	add	a1,a5,sp
   118c4:	846e                	mv	s0,s11
   118c6:	856e                	mv	a0,s11
   118c8:	a68ff0ef          	jal	10b30 <strcpy@plt>
   118cc:	854e                	mv	a0,s3
   118ce:	902ff0ef          	jal	109d0 <close@plt>
   118d2:	65c9                	lui	a1,0x12
   118d4:	3ec58593          	add	a1,a1,1004 # 123ec <_IO_stdin_used+0x910>
   118d8:	856e                	mv	a0,s11
   118da:	a46ff0ef          	jal	10b20 <strcmp@plt>
   118de:	00a03533          	snez	a0,a0
   118e2:	40a00533          	neg	a0,a0
   118e6:	62a9                	lui	t0,0xa
   118e8:	9116                	add	sp,sp,t0
   118ea:	50f6                	lw	ra,124(sp)
   118ec:	5466                	lw	s0,120(sp)
   118ee:	54d6                	lw	s1,116(sp)
   118f0:	5946                	lw	s2,112(sp)
   118f2:	59b6                	lw	s3,108(sp)
   118f4:	5a26                	lw	s4,104(sp)
   118f6:	5a96                	lw	s5,100(sp)
   118f8:	5b06                	lw	s6,96(sp)
   118fa:	4bf6                	lw	s7,92(sp)
   118fc:	4c66                	lw	s8,88(sp)
   118fe:	4cd6                	lw	s9,84(sp)
   11900:	4d46                	lw	s10,80(sp)
   11902:	4db6                	lw	s11,76(sp)
   11904:	6109                	add	sp,sp,128
   11906:	8082                	ret
   11908:	03800613          	li	a2,56
   1190c:	65c9                	lui	a1,0x12
   1190e:	3b458593          	add	a1,a1,948 # 123b4 <_IO_stdin_used+0x8d8>
   11912:	856e                	mv	a0,s11
   11914:	9acff0ef          	jal	10ac0 <memcpy@plt>
   11918:	854e                	mv	a0,s3
   1191a:	8b6ff0ef          	jal	109d0 <close@plt>
   1191e:	557d                	li	a0,-1
   11920:	b7d9                	j	118e6 <submitr+0x3d8>
   11922:	04300613          	li	a2,67
   11926:	65c9                	lui	a1,0x12
   11928:	3f058593          	add	a1,a1,1008 # 123f0 <_IO_stdin_used+0x914>
   1192c:	856e                	mv	a0,s11
   1192e:	992ff0ef          	jal	10ac0 <memcpy@plt>
   11932:	854e                	mv	a0,s3
   11934:	89cff0ef          	jal	109d0 <close@plt>
   11938:	557d                	li	a0,-1
   1193a:	b775                	j	118e6 <submitr+0x3d8>

0001193c <init_timeout>:
   1193c:	e111                	bnez	a0,11940 <init_timeout+0x4>
   1193e:	8082                	ret
   11940:	1141                	add	sp,sp,-16
   11942:	c606                	sw	ra,12(sp)
   11944:	c422                	sw	s0,8(sp)
   11946:	842a                	mv	s0,a0
   11948:	65c5                	lui	a1,0x11
   1194a:	41858593          	add	a1,a1,1048 # 11418 <sigalrm_handler>
   1194e:	4539                	li	a0,14
   11950:	8f0ff0ef          	jal	10a40 <signal@plt>
   11954:	fff44793          	not	a5,s0
   11958:	87fd                	sra	a5,a5,0x1f
   1195a:	00f47533          	and	a0,s0,a5
   1195e:	862ff0ef          	jal	109c0 <alarm@plt>
   11962:	40b2                	lw	ra,12(sp)
   11964:	4422                	lw	s0,8(sp)
   11966:	0141                	add	sp,sp,16
   11968:	8082                	ret

0001196a <init_driver>:
   1196a:	1101                	add	sp,sp,-32
   1196c:	ce06                	sw	ra,28(sp)
   1196e:	ca26                	sw	s1,20(sp)
   11970:	84aa                	mv	s1,a0
   11972:	4585                	li	a1,1
   11974:	4535                	li	a0,13
   11976:	8caff0ef          	jal	10a40 <signal@plt>
   1197a:	4585                	li	a1,1
   1197c:	4575                	li	a0,29
   1197e:	8c2ff0ef          	jal	10a40 <signal@plt>
   11982:	4585                	li	a1,1
   11984:	4575                	li	a0,29
   11986:	8baff0ef          	jal	10a40 <signal@plt>
   1198a:	4601                	li	a2,0
   1198c:	4585                	li	a1,1
   1198e:	4509                	li	a0,2
   11990:	8a0ff0ef          	jal	10a30 <socket@plt>
   11994:	08054063          	bltz	a0,11a14 <init_driver+0xaa>
   11998:	cc22                	sw	s0,24(sp)
   1199a:	842a                	mv	s0,a0
   1199c:	6549                	lui	a0,0x12
   1199e:	43450513          	add	a0,a0,1076 # 12434 <_IO_stdin_used+0x958>
   119a2:	90eff0ef          	jal	10ab0 <gethostbyname@plt>
   119a6:	c149                	beqz	a0,11a28 <init_driver+0xbe>
   119a8:	00011123          	sh	zero,2(sp)
   119ac:	00011223          	sh	zero,4(sp)
   119b0:	00011323          	sh	zero,6(sp)
   119b4:	00011423          	sh	zero,8(sp)
   119b8:	00011523          	sh	zero,10(sp)
   119bc:	00011623          	sh	zero,12(sp)
   119c0:	00011723          	sh	zero,14(sp)
   119c4:	4789                	li	a5,2
   119c6:	00f11023          	sh	a5,0(sp)
   119ca:	491c                	lw	a5,16(a0)
   119cc:	4550                	lw	a2,12(a0)
   119ce:	438c                	lw	a1,0(a5)
   119d0:	0048                	add	a0,sp,4
   119d2:	91eff0ef          	jal	10af0 <memmove@plt>
   119d6:	679d                	lui	a5,0x7
   119d8:	e3b78793          	add	a5,a5,-453 # 6e3b <_PROCEDURE_LINKAGE_TABLE_-0x9af5>
   119dc:	00f11123          	sh	a5,2(sp)
   119e0:	4641                	li	a2,16
   119e2:	858a                	mv	a1,sp
   119e4:	8522                	mv	a0,s0
   119e6:	92aff0ef          	jal	10b10 <connect@plt>
   119ea:	04054d63          	bltz	a0,11a44 <init_driver+0xda>
   119ee:	8522                	mv	a0,s0
   119f0:	fe1fe0ef          	jal	109d0 <close@plt>
   119f4:	04f00793          	li	a5,79
   119f8:	00f48023          	sb	a5,0(s1)
   119fc:	04b00793          	li	a5,75
   11a00:	00f480a3          	sb	a5,1(s1)
   11a04:	00048123          	sb	zero,2(s1)
   11a08:	4501                	li	a0,0
   11a0a:	4462                	lw	s0,24(sp)
   11a0c:	40f2                	lw	ra,28(sp)
   11a0e:	44d2                	lw	s1,20(sp)
   11a10:	6105                	add	sp,sp,32
   11a12:	8082                	ret
   11a14:	02600613          	li	a2,38
   11a18:	65c9                	lui	a1,0x12
   11a1a:	1bc58593          	add	a1,a1,444 # 121bc <_IO_stdin_used+0x6e0>
   11a1e:	8526                	mv	a0,s1
   11a20:	8a0ff0ef          	jal	10ac0 <memcpy@plt>
   11a24:	557d                	li	a0,-1
   11a26:	b7dd                	j	11a0c <init_driver+0xa2>
   11a28:	02f00613          	li	a2,47
   11a2c:	65c9                	lui	a1,0x12
   11a2e:	1e458593          	add	a1,a1,484 # 121e4 <_IO_stdin_used+0x708>
   11a32:	8526                	mv	a0,s1
   11a34:	88cff0ef          	jal	10ac0 <memcpy@plt>
   11a38:	8522                	mv	a0,s0
   11a3a:	f97fe0ef          	jal	109d0 <close@plt>
   11a3e:	557d                	li	a0,-1
   11a40:	4462                	lw	s0,24(sp)
   11a42:	b7e9                	j	11a0c <init_driver+0xa2>
   11a44:	6649                	lui	a2,0x12
   11a46:	43460613          	add	a2,a2,1076 # 12434 <_IO_stdin_used+0x958>
   11a4a:	65c9                	lui	a1,0x12
   11a4c:	44458593          	add	a1,a1,1092 # 12444 <_IO_stdin_used+0x968>
   11a50:	8526                	mv	a0,s1
   11a52:	fcffe0ef          	jal	10a20 <sprintf@plt>
   11a56:	8522                	mv	a0,s0
   11a58:	f79fe0ef          	jal	109d0 <close@plt>
   11a5c:	557d                	li	a0,-1
   11a5e:	4462                	lw	s0,24(sp)
   11a60:	b775                	j	11a0c <init_driver+0xa2>

00011a62 <driver_post>:
   11a62:	1141                	add	sp,sp,-16
   11a64:	c606                	sw	ra,12(sp)
   11a66:	c422                	sw	s0,8(sp)
   11a68:	843a                	mv	s0,a4
   11a6a:	e685                	bnez	a3,11a92 <driver_post+0x30>
   11a6c:	c501                	beqz	a0,11a74 <driver_post+0x12>
   11a6e:	00054783          	lbu	a5,0(a0)
   11a72:	e3b1                	bnez	a5,11ab6 <driver_post+0x54>
   11a74:	04f00793          	li	a5,79
   11a78:	00f40023          	sb	a5,0(s0)
   11a7c:	04b00793          	li	a5,75
   11a80:	00f400a3          	sb	a5,1(s0)
   11a84:	00040123          	sb	zero,2(s0)
   11a88:	8536                	mv	a0,a3
   11a8a:	40b2                	lw	ra,12(sp)
   11a8c:	4422                	lw	s0,8(sp)
   11a8e:	0141                	add	sp,sp,16
   11a90:	8082                	ret
   11a92:	85b2                	mv	a1,a2
   11a94:	6549                	lui	a0,0x12
   11a96:	46c50513          	add	a0,a0,1132 # 1246c <_IO_stdin_used+0x990>
   11a9a:	f07fe0ef          	jal	109a0 <printf@plt>
   11a9e:	04f00793          	li	a5,79
   11aa2:	00f40023          	sb	a5,0(s0)
   11aa6:	04b00793          	li	a5,75
   11aaa:	00f400a3          	sb	a5,1(s0)
   11aae:	00040123          	sb	zero,2(s0)
   11ab2:	4501                	li	a0,0
   11ab4:	bfd9                	j	11a8a <driver_post+0x28>
   11ab6:	88ba                	mv	a7,a4
   11ab8:	8832                	mv	a6,a2
   11aba:	67c9                	lui	a5,0x12
   11abc:	48478793          	add	a5,a5,1156 # 12484 <_IO_stdin_used+0x9a8>
   11ac0:	872e                	mv	a4,a1
   11ac2:	86aa                	mv	a3,a0
   11ac4:	6649                	lui	a2,0x12
   11ac6:	48860613          	add	a2,a2,1160 # 12488 <_IO_stdin_used+0x9ac>
   11aca:	6591                	lui	a1,0x4
   11acc:	b6e58593          	add	a1,a1,-1170 # 3b6e <_PROCEDURE_LINKAGE_TABLE_-0xcdc2>
   11ad0:	6549                	lui	a0,0x12
   11ad2:	43450513          	add	a0,a0,1076 # 12434 <_IO_stdin_used+0x958>
   11ad6:	3c25                	jal	1150e <submitr>
   11ad8:	bf4d                	j	11a8a <driver_post+0x28>
