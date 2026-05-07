
bomb:     file format elf32-littleriscv


Disassembly of section .plt:

00010490 <_PROCEDURE_LINKAGE_TABLE_>:
   10490:	97 33 00 00 33 03 c3 41 03 ae 83 b6 13 03 43 fd     .3..3..A......C.
   104a0:	93 82 83 b6 13 53 23 00 83 a2 42 00 67 00 0e 00     .....S#...B.g...

000104b0 <__libc_start_main@plt>:
   104b0:	00003e17          	auipc	t3,0x3
   104b4:	b50e2e03          	lw	t3,-1200(t3) # 13000 <__libc_start_main@GLIBC_2.34>
   104b8:	000e0367          	jalr	t1,t3
   104bc:	00000013          	nop

000104c0 <__isoc23_sscanf@plt>:
   104c0:	00003e17          	auipc	t3,0x3
   104c4:	b44e2e03          	lw	t3,-1212(t3) # 13004 <__isoc23_sscanf@GLIBC_2.38>
   104c8:	000e0367          	jalr	t1,t3
   104cc:	00000013          	nop

000104d0 <printf@plt>:
   104d0:	00003e17          	auipc	t3,0x3
   104d4:	b38e2e03          	lw	t3,-1224(t3) # 13008 <printf@GLIBC_2.33>
   104d8:	000e0367          	jalr	t1,t3
   104dc:	00000013          	nop

000104e0 <puts@plt>:
   104e0:	00003e17          	auipc	t3,0x3
   104e4:	b2ce2e03          	lw	t3,-1236(t3) # 1300c <puts@GLIBC_2.33>
   104e8:	000e0367          	jalr	t1,t3
   104ec:	00000013          	nop

000104f0 <__ctype_b_loc@plt>:
   104f0:	00003e17          	auipc	t3,0x3
   104f4:	b20e2e03          	lw	t3,-1248(t3) # 13010 <__ctype_b_loc@GLIBC_2.33>
   104f8:	000e0367          	jalr	t1,t3
   104fc:	00000013          	nop

00010500 <exit@plt>:
   10500:	00003e17          	auipc	t3,0x3
   10504:	b14e2e03          	lw	t3,-1260(t3) # 13014 <exit@GLIBC_2.33>
   10508:	000e0367          	jalr	t1,t3
   1050c:	00000013          	nop

00010510 <fopen@plt>:
   10510:	00003e17          	auipc	t3,0x3
   10514:	b08e2e03          	lw	t3,-1272(t3) # 13018 <fopen@GLIBC_2.33>
   10518:	000e0367          	jalr	t1,t3
   1051c:	00000013          	nop

00010520 <strlen@plt>:
   10520:	00003e17          	auipc	t3,0x3
   10524:	afce2e03          	lw	t3,-1284(t3) # 1301c <strlen@GLIBC_2.33>
   10528:	000e0367          	jalr	t1,t3
   1052c:	00000013          	nop

00010530 <fgets@plt>:
   10530:	00003e17          	auipc	t3,0x3
   10534:	af0e2e03          	lw	t3,-1296(t3) # 13020 <fgets@GLIBC_2.33>
   10538:	000e0367          	jalr	t1,t3
   1053c:	00000013          	nop

00010540 <strcmp@plt>:
   10540:	00003e17          	auipc	t3,0x3
   10544:	ae4e2e03          	lw	t3,-1308(t3) # 13024 <strcmp@GLIBC_2.33>
   10548:	000e0367          	jalr	t1,t3
   1054c:	00000013          	nop

Disassembly of section .text:

00010550 <_start>:
   10550:	2005                	jal	10570 <load_gp>
   10552:	87aa                	mv	a5,a0
   10554:	00000517          	auipc	a0,0x0
   10558:	01a50513          	add	a0,a0,26 # 1056e <__wrap_main>
   1055c:	4582                	lw	a1,0(sp)
   1055e:	0050                	add	a2,sp,4
   10560:	ff017113          	and	sp,sp,-16
   10564:	4681                	li	a3,0
   10566:	4701                	li	a4,0
   10568:	880a                	mv	a6,sp
   1056a:	3799                	jal	104b0 <__libc_start_main@plt>
   1056c:	9002                	ebreak

0001056e <__wrap_main>:
   1056e:	a0ad                	j	105d8 <main>

00010570 <load_gp>:
   10570:	00003197          	auipc	gp,0x3
   10574:	2b818193          	add	gp,gp,696 # 13828 <__global_pointer$>
   10578:	8082                	ret
   1057a:	0001                	nop

0001057c <_dl_relocate_static_pie>:
   1057c:	8082                	ret

0001057e <deregister_tm_clones>:
   1057e:	654d                	lui	a0,0x13
   10580:	67cd                	lui	a5,0x13
   10582:	02850513          	add	a0,a0,40 # 13028 <__TMC_END__>
   10586:	02878793          	add	a5,a5,40 # 13028 <__TMC_END__>
   1058a:	00a78663          	beq	a5,a0,10596 <deregister_tm_clones+0x18>
   1058e:	00000793          	li	a5,0
   10592:	c391                	beqz	a5,10596 <deregister_tm_clones+0x18>
   10594:	8782                	jr	a5
   10596:	8082                	ret

00010598 <register_tm_clones>:
   10598:	654d                	lui	a0,0x13
   1059a:	67cd                	lui	a5,0x13
   1059c:	02850513          	add	a0,a0,40 # 13028 <__TMC_END__>
   105a0:	02878593          	add	a1,a5,40 # 13028 <__TMC_END__>
   105a4:	8d89                	sub	a1,a1,a0
   105a6:	4025d793          	sra	a5,a1,0x2
   105aa:	81fd                	srl	a1,a1,0x1f
   105ac:	95be                	add	a1,a1,a5
   105ae:	8585                	sra	a1,a1,0x1
   105b0:	c589                	beqz	a1,105ba <register_tm_clones+0x22>
   105b2:	00000793          	li	a5,0
   105b6:	c391                	beqz	a5,105ba <register_tm_clones+0x22>
   105b8:	8782                	jr	a5
   105ba:	8082                	ret

000105bc <__do_global_dtors_aux>:
   105bc:	8141c703          	lbu	a4,-2028(gp) # 1303c <completed.0>
   105c0:	eb11                	bnez	a4,105d4 <__do_global_dtors_aux+0x18>
   105c2:	1141                	add	sp,sp,-16
   105c4:	c606                	sw	ra,12(sp)
   105c6:	3f65                	jal	1057e <deregister_tm_clones>
   105c8:	40b2                	lw	ra,12(sp)
   105ca:	4705                	li	a4,1
   105cc:	80e18a23          	sb	a4,-2028(gp) # 1303c <completed.0>
   105d0:	0141                	add	sp,sp,16
   105d2:	8082                	ret
   105d4:	8082                	ret

000105d6 <frame_dummy>:
   105d6:	b7c9                	j	10598 <register_tm_clones>

000105d8 <main>:
   105d8:	1141                	add	sp,sp,-16
   105da:	c606                	sw	ra,12(sp)
   105dc:	4785                	li	a5,1
   105de:	06f50f63          	beq	a0,a5,1065c <main+0x84>
   105e2:	c422                	sw	s0,8(sp)
   105e4:	842e                	mv	s0,a1
   105e6:	4789                	li	a5,2
   105e8:	08f51863          	bne	a0,a5,10678 <main+0xa0>
   105ec:	65c5                	lui	a1,0x11
   105ee:	91458593          	add	a1,a1,-1772 # 10914 <_IO_stdin_used+0x4>
   105f2:	4048                	lw	a0,4(s0)
   105f4:	3f31                	jal	10510 <fopen@plt>
   105f6:	67cd                	lui	a5,0x13
   105f8:	02a7a623          	sw	a0,44(a5) # 1302c <infile>
   105fc:	c535                	beqz	a0,10668 <main+0x90>
   105fe:	4422                	lw	s0,8(sp)
   10600:	6545                	lui	a0,0x11
   10602:	95450513          	add	a0,a0,-1708 # 10954 <_IO_stdin_used+0x44>
   10606:	3de9                	jal	104e0 <puts@plt>
   10608:	6545                	lui	a0,0x11
   1060a:	98c50513          	add	a0,a0,-1652 # 1098c <_IO_stdin_used+0x7c>
   1060e:	3dc9                	jal	104e0 <puts@plt>
   10610:	6545                	lui	a0,0x11
   10612:	9d850513          	add	a0,a0,-1576 # 109d8 <_IO_stdin_used+0xc8>
   10616:	35e9                	jal	104e0 <puts@plt>
   10618:	6545                	lui	a0,0x11
   1061a:	a2450513          	add	a0,a0,-1500 # 10a24 <_IO_stdin_used+0x114>
   1061e:	35c9                	jal	104e0 <puts@plt>
   10620:	22dd                	jal	10806 <read_line>
   10622:	2095                	jal	10686 <phase_1>
   10624:	24e9                	jal	108ee <phase_defused>
   10626:	6545                	lui	a0,0x11
   10628:	a6c50513          	add	a0,a0,-1428 # 10a6c <_IO_stdin_used+0x15c>
   1062c:	3d55                	jal	104e0 <puts@plt>
   1062e:	2ae1                	jal	10806 <read_line>
   10630:	20bd                	jal	1069e <phase_2>
   10632:	2c75                	jal	108ee <phase_defused>
   10634:	6545                	lui	a0,0x11
   10636:	a9c50513          	add	a0,a0,-1380 # 10a9c <_IO_stdin_used+0x18c>
   1063a:	355d                	jal	104e0 <puts@plt>
   1063c:	6545                	lui	a0,0x11
   1063e:	acc50513          	add	a0,a0,-1332 # 10acc <_IO_stdin_used+0x1bc>
   10642:	3d79                	jal	104e0 <puts@plt>
   10644:	6545                	lui	a0,0x11
   10646:	b0850513          	add	a0,a0,-1272 # 10b08 <_IO_stdin_used+0x1f8>
   1064a:	3d59                	jal	104e0 <puts@plt>
   1064c:	6545                	lui	a0,0x11
   1064e:	b4850513          	add	a0,a0,-1208 # 10b48 <_IO_stdin_used+0x238>
   10652:	3579                	jal	104e0 <puts@plt>
   10654:	4501                	li	a0,0
   10656:	40b2                	lw	ra,12(sp)
   10658:	0141                	add	sp,sp,16
   1065a:	8082                	ret
   1065c:	8101a703          	lw	a4,-2032(gp) # 13038 <stdin@GLIBC_2.33>
   10660:	67cd                	lui	a5,0x13
   10662:	02e7a623          	sw	a4,44(a5) # 1302c <infile>
   10666:	bf69                	j	10600 <main+0x28>
   10668:	4050                	lw	a2,4(s0)
   1066a:	400c                	lw	a1,0(s0)
   1066c:	6545                	lui	a0,0x11
   1066e:	91850513          	add	a0,a0,-1768 # 10918 <_IO_stdin_used+0x8>
   10672:	3db9                	jal	104d0 <printf@plt>
   10674:	4521                	li	a0,8
   10676:	3569                	jal	10500 <exit@plt>
   10678:	418c                	lw	a1,0(a1)
   1067a:	6545                	lui	a0,0x11
   1067c:	93850513          	add	a0,a0,-1736 # 10938 <_IO_stdin_used+0x28>
   10680:	3d81                	jal	104d0 <printf@plt>
   10682:	4521                	li	a0,8
   10684:	3db5                	jal	10500 <exit@plt>

00010686 <phase_1>:
   10686:	1141                	add	sp,sp,-16
   10688:	c606                	sw	ra,12(sp)
   1068a:	65c5                	lui	a1,0x11
   1068c:	b6058593          	add	a1,a1,-1184 # 10b60 <_IO_stdin_used+0x250>
   10690:	3d45                	jal	10540 <strcmp@plt>
   10692:	e501                	bnez	a0,1069a <phase_1+0x14>
   10694:	40b2                	lw	ra,12(sp)
   10696:	0141                	add	sp,sp,16
   10698:	8082                	ret
   1069a:	2211                	jal	1079e <explode_bomb>
   1069c:	bfe5                	j	10694 <phase_1+0xe>

0001069e <phase_2>:
   1069e:	7179                	add	sp,sp,-48
   106a0:	d606                	sw	ra,44(sp)
   106a2:	d422                	sw	s0,40(sp)
   106a4:	d226                	sw	s1,36(sp)
   106a6:	d04a                	sw	s2,32(sp)
   106a8:	ce4e                	sw	s3,28(sp)
   106aa:	cc52                	sw	s4,24(sp)
   106ac:	858a                	mv	a1,sp
   106ae:	2c21                	jal	108c6 <read_four_ints>
   106b0:	4482                	lw	s1,0(sp)
   106b2:	4912                	lw	s2,4(sp)
   106b4:	4422                	lw	s0,8(sp)
   106b6:	49b2                	lw	s3,12(sp)
   106b8:	ff648793          	add	a5,s1,-10
   106bc:	ef91                	bnez	a5,106d8 <phase_2+0x3a>
   106be:	ff490793          	add	a5,s2,-12
   106c2:	eb99                	bnez	a5,106d8 <phase_2+0x3a>
   106c4:	4795                	li	a5,5
   106c6:	0487e663          	bltu	a5,s0,10712 <phase_2+0x74>
   106ca:	040a                	sll	s0,s0,0x2
   106cc:	67c5                	lui	a5,0x11
   106ce:	e2878793          	add	a5,a5,-472 # 10e28 <_IO_stdin_used+0x518>
   106d2:	943e                	add	s0,s0,a5
   106d4:	401c                	lw	a5,0(s0)
   106d6:	8782                	jr	a5
   106d8:	20d9                	jal	1079e <explode_bomb>
   106da:	b7ed                	j	106c4 <phase_2+0x26>
   106dc:	01248a33          	add	s4,s1,s2
   106e0:	033a1b63          	bne	s4,s3,10716 <phase_2+0x78>
   106e4:	50b2                	lw	ra,44(sp)
   106e6:	5422                	lw	s0,40(sp)
   106e8:	5492                	lw	s1,36(sp)
   106ea:	5902                	lw	s2,32(sp)
   106ec:	49f2                	lw	s3,28(sp)
   106ee:	4a62                	lw	s4,24(sp)
   106f0:	6145                	add	sp,sp,48
   106f2:	8082                	ret
   106f4:	41248a33          	sub	s4,s1,s2
   106f8:	b7e5                	j	106e0 <phase_2+0x42>
   106fa:	03248a33          	mul	s4,s1,s2
   106fe:	b7cd                	j	106e0 <phase_2+0x42>
   10700:	0124fa33          	and	s4,s1,s2
   10704:	bff1                	j	106e0 <phase_2+0x42>
   10706:	0124ea33          	or	s4,s1,s2
   1070a:	bfd9                	j	106e0 <phase_2+0x42>
   1070c:	0124ca33          	xor	s4,s1,s2
   10710:	bfc1                	j	106e0 <phase_2+0x42>
   10712:	2071                	jal	1079e <explode_bomb>
   10714:	b7f1                	j	106e0 <phase_2+0x42>
   10716:	2061                	jal	1079e <explode_bomb>
   10718:	b7f1                	j	106e4 <phase_2+0x46>

0001071a <blank_line>:
   1071a:	1141                	add	sp,sp,-16
   1071c:	c606                	sw	ra,12(sp)
   1071e:	c422                	sw	s0,8(sp)
   10720:	c226                	sw	s1,4(sp)
   10722:	c04a                	sw	s2,0(sp)
   10724:	84aa                	mv	s1,a0
   10726:	6909                	lui	s2,0x2
   10728:	0004c403          	lbu	s0,0(s1)
   1072c:	cc09                	beqz	s0,10746 <blank_line+0x2c>
   1072e:	33c9                	jal	104f0 <__ctype_b_loc@plt>
   10730:	0485                	add	s1,s1,1
   10732:	411c                	lw	a5,0(a0)
   10734:	0406                	sll	s0,s0,0x1
   10736:	97a2                	add	a5,a5,s0
   10738:	0007d783          	lhu	a5,0(a5)
   1073c:	0127f7b3          	and	a5,a5,s2
   10740:	f7e5                	bnez	a5,10728 <blank_line+0xe>
   10742:	4501                	li	a0,0
   10744:	a011                	j	10748 <blank_line+0x2e>
   10746:	4505                	li	a0,1
   10748:	40b2                	lw	ra,12(sp)
   1074a:	4422                	lw	s0,8(sp)
   1074c:	4492                	lw	s1,4(sp)
   1074e:	4902                	lw	s2,0(sp)
   10750:	0141                	add	sp,sp,16
   10752:	8082                	ret

00010754 <skip>:
   10754:	1101                	add	sp,sp,-32
   10756:	ce06                	sw	ra,28(sp)
   10758:	cc22                	sw	s0,24(sp)
   1075a:	ca26                	sw	s1,20(sp)
   1075c:	c84a                	sw	s2,16(sp)
   1075e:	c64e                	sw	s3,12(sp)
   10760:	c452                	sw	s4,8(sp)
   10762:	6a4d                	lui	s4,0x13
   10764:	81818493          	add	s1,gp,-2024 # 13040 <input_strings>
   10768:	69cd                	lui	s3,0x13
   1076a:	05000913          	li	s2,80
   1076e:	0309a783          	lw	a5,48(s3) # 13030 <num_input_strings>
   10772:	00279513          	sll	a0,a5,0x2
   10776:	953e                	add	a0,a0,a5
   10778:	0512                	sll	a0,a0,0x4
   1077a:	02ca2603          	lw	a2,44(s4) # 1302c <infile>
   1077e:	85ca                	mv	a1,s2
   10780:	9526                	add	a0,a0,s1
   10782:	337d                	jal	10530 <fgets@plt>
   10784:	842a                	mv	s0,a0
   10786:	c119                	beqz	a0,1078c <skip+0x38>
   10788:	3f49                	jal	1071a <blank_line>
   1078a:	f175                	bnez	a0,1076e <skip+0x1a>
   1078c:	8522                	mv	a0,s0
   1078e:	40f2                	lw	ra,28(sp)
   10790:	4462                	lw	s0,24(sp)
   10792:	44d2                	lw	s1,20(sp)
   10794:	4942                	lw	s2,16(sp)
   10796:	49b2                	lw	s3,12(sp)
   10798:	4a22                	lw	s4,8(sp)
   1079a:	6105                	add	sp,sp,32
   1079c:	8082                	ret

0001079e <explode_bomb>:
   1079e:	1141                	add	sp,sp,-16
   107a0:	c606                	sw	ra,12(sp)
   107a2:	c422                	sw	s0,8(sp)
   107a4:	c226                	sw	s1,4(sp)
   107a6:	6545                	lui	a0,0x11
   107a8:	b9c50513          	add	a0,a0,-1124 # 10b9c <_IO_stdin_used+0x28c>
   107ac:	3315                	jal	104d0 <printf@plt>
   107ae:	6445                	lui	s0,0x11
   107b0:	bd440513          	add	a0,s0,-1068 # 10bd4 <_IO_stdin_used+0x2c4>
   107b4:	3b31                	jal	104d0 <printf@plt>
   107b6:	6545                	lui	a0,0x11
   107b8:	c0c50513          	add	a0,a0,-1012 # 10c0c <_IO_stdin_used+0x2fc>
   107bc:	3b11                	jal	104d0 <printf@plt>
   107be:	6545                	lui	a0,0x11
   107c0:	c4450513          	add	a0,a0,-956 # 10c44 <_IO_stdin_used+0x334>
   107c4:	3331                	jal	104d0 <printf@plt>
   107c6:	6545                	lui	a0,0x11
   107c8:	c7c50513          	add	a0,a0,-900 # 10c7c <_IO_stdin_used+0x36c>
   107cc:	3311                	jal	104d0 <printf@plt>
   107ce:	64c5                	lui	s1,0x11
   107d0:	cb448513          	add	a0,s1,-844 # 10cb4 <_IO_stdin_used+0x3a4>
   107d4:	39f5                	jal	104d0 <printf@plt>
   107d6:	cb448513          	add	a0,s1,-844
   107da:	39dd                	jal	104d0 <printf@plt>
   107dc:	6545                	lui	a0,0x11
   107de:	cec50513          	add	a0,a0,-788 # 10cec <_IO_stdin_used+0x3dc>
   107e2:	31fd                	jal	104d0 <printf@plt>
   107e4:	bd440513          	add	a0,s0,-1068
   107e8:	39e5                	jal	104e0 <puts@plt>
   107ea:	6545                	lui	a0,0x11
   107ec:	d2450513          	add	a0,a0,-732 # 10d24 <_IO_stdin_used+0x414>
   107f0:	39c5                	jal	104e0 <puts@plt>
   107f2:	6545                	lui	a0,0x11
   107f4:	d3c50513          	add	a0,a0,-708 # 10d3c <_IO_stdin_used+0x42c>
   107f8:	31e5                	jal	104e0 <puts@plt>
   107fa:	6545                	lui	a0,0x11
   107fc:	d6c50513          	add	a0,a0,-660 # 10d6c <_IO_stdin_used+0x45c>
   10800:	31c5                	jal	104e0 <puts@plt>
   10802:	4521                	li	a0,8
   10804:	39f5                	jal	10500 <exit@plt>

00010806 <read_line>:
   10806:	1141                	add	sp,sp,-16
   10808:	c606                	sw	ra,12(sp)
   1080a:	c422                	sw	s0,8(sp)
   1080c:	c226                	sw	s1,4(sp)
   1080e:	3799                	jal	10754 <skip>
   10810:	c529                	beqz	a0,1085a <read_line+0x54>
   10812:	67cd                	lui	a5,0x13
   10814:	0307a403          	lw	s0,48(a5) # 13030 <num_input_strings>
   10818:	00241793          	sll	a5,s0,0x2
   1081c:	97a2                	add	a5,a5,s0
   1081e:	0792                	sll	a5,a5,0x4
   10820:	81818493          	add	s1,gp,-2024 # 13040 <input_strings>
   10824:	94be                	add	s1,s1,a5
   10826:	8526                	mv	a0,s1
   10828:	39e5                	jal	10520 <strlen@plt>
   1082a:	04e00793          	li	a5,78
   1082e:	04a7ce63          	blt	a5,a0,1088a <read_line+0x84>
   10832:	00241713          	sll	a4,s0,0x2
   10836:	9722                	add	a4,a4,s0
   10838:	0712                	sll	a4,a4,0x4
   1083a:	81818793          	add	a5,gp,-2024 # 13040 <input_strings>
   1083e:	97ba                	add	a5,a5,a4
   10840:	953e                	add	a0,a0,a5
   10842:	fe050fa3          	sb	zero,-1(a0)
   10846:	0405                	add	s0,s0,1
   10848:	67cd                	lui	a5,0x13
   1084a:	0287a823          	sw	s0,48(a5) # 13030 <num_input_strings>
   1084e:	8526                	mv	a0,s1
   10850:	40b2                	lw	ra,12(sp)
   10852:	4422                	lw	s0,8(sp)
   10854:	4492                	lw	s1,4(sp)
   10856:	0141                	add	sp,sp,16
   10858:	8082                	ret
   1085a:	8101a783          	lw	a5,-2032(gp) # 13038 <stdin@GLIBC_2.33>
   1085e:	674d                	lui	a4,0x13
   10860:	02c72703          	lw	a4,44(a4) # 1302c <infile>
   10864:	00f70d63          	beq	a4,a5,1087e <read_line+0x78>
   10868:	674d                	lui	a4,0x13
   1086a:	02f72623          	sw	a5,44(a4) # 1302c <infile>
   1086e:	35dd                	jal	10754 <skip>
   10870:	f14d                	bnez	a0,10812 <read_line+0xc>
   10872:	6545                	lui	a0,0x11
   10874:	d9c50513          	add	a0,a0,-612 # 10d9c <_IO_stdin_used+0x48c>
   10878:	31a5                	jal	104e0 <puts@plt>
   1087a:	4501                	li	a0,0
   1087c:	3151                	jal	10500 <exit@plt>
   1087e:	6545                	lui	a0,0x11
   10880:	d9c50513          	add	a0,a0,-612 # 10d9c <_IO_stdin_used+0x48c>
   10884:	39b1                	jal	104e0 <puts@plt>
   10886:	4521                	li	a0,8
   10888:	39a5                	jal	10500 <exit@plt>
   1088a:	6545                	lui	a0,0x11
   1088c:	dbc50513          	add	a0,a0,-580 # 10dbc <_IO_stdin_used+0x4ac>
   10890:	3981                	jal	104e0 <puts@plt>
   10892:	674d                	lui	a4,0x13
   10894:	03072783          	lw	a5,48(a4) # 13030 <num_input_strings>
   10898:	00178693          	add	a3,a5,1
   1089c:	02d72823          	sw	a3,48(a4)
   108a0:	05000713          	li	a4,80
   108a4:	02e78733          	mul	a4,a5,a4
   108a8:	81818793          	add	a5,gp,-2024 # 13040 <input_strings>
   108ac:	97ba                	add	a5,a5,a4
   108ae:	6745                	lui	a4,0x11
   108b0:	dd870713          	add	a4,a4,-552 # 10dd8 <_IO_stdin_used+0x4c8>
   108b4:	430c                	lw	a1,0(a4)
   108b6:	4350                	lw	a2,4(a4)
   108b8:	4714                	lw	a3,8(a4)
   108ba:	c38c                	sw	a1,0(a5)
   108bc:	c3d0                	sw	a2,4(a5)
   108be:	c794                	sw	a3,8(a5)
   108c0:	4758                	lw	a4,12(a4)
   108c2:	c7d8                	sw	a4,12(a5)
   108c4:	3de9                	jal	1079e <explode_bomb>

000108c6 <read_four_ints>:
   108c6:	1141                	add	sp,sp,-16
   108c8:	c606                	sw	ra,12(sp)
   108ca:	862e                	mv	a2,a1
   108cc:	00c58793          	add	a5,a1,12
   108d0:	00858713          	add	a4,a1,8
   108d4:	00458693          	add	a3,a1,4
   108d8:	65c5                	lui	a1,0x11
   108da:	de858593          	add	a1,a1,-536 # 10de8 <_IO_stdin_used+0x4d8>
   108de:	36cd                	jal	104c0 <__isoc23_sscanf@plt>
   108e0:	4791                	li	a5,4
   108e2:	00f51563          	bne	a0,a5,108ec <read_four_ints+0x26>
   108e6:	40b2                	lw	ra,12(sp)
   108e8:	0141                	add	sp,sp,16
   108ea:	8082                	ret
   108ec:	3d4d                	jal	1079e <explode_bomb>

000108ee <phase_defused>:
   108ee:	67cd                	lui	a5,0x13
   108f0:	0307a703          	lw	a4,48(a5) # 13030 <num_input_strings>
   108f4:	4789                	li	a5,2
   108f6:	00f70363          	beq	a4,a5,108fc <phase_defused+0xe>
   108fa:	8082                	ret
   108fc:	1141                	add	sp,sp,-16
   108fe:	c606                	sw	ra,12(sp)
   10900:	6545                	lui	a0,0x11
   10902:	df450513          	add	a0,a0,-524 # 10df4 <_IO_stdin_used+0x4e4>
   10906:	3ee9                	jal	104e0 <puts@plt>
   10908:	40b2                	lw	ra,12(sp)
   1090a:	0141                	add	sp,sp,16
   1090c:	8082                	ret
