                        :BasicUpstart2(main)

                        .pc = $c000 "Code"
main:                           
                        sei                                     // set interupt status
                        lda #<irq                               // This sets up the memory address where the IRQ starts                 
                        ldx #>irq                               // using high byte and low byte format                  
                        sta $0314                               // More information on IRQ setups at this website
                        stx $0315                               // http://dustlayer.com/c64-coding-tutorials/2013/4/8/episode-2-3-did-i-interrupt-you
                        
                        lda #$7f                                // set the CIA Interrupt Control Register           
                        sta $dc0d                               
                        lda #$20
                        sta $dc0e                               // set the CIA Control Register A
                        lda #$0
                        sta $d012                               // set Read Raster/Write Raster Value for Compare IRQ
                        lda #$01                            
                        sta $d01a                               // IRQ Mask Register: 1 = Interrupt Enabled
                        cli                                     // CLI Clear interrupt disable bit 
                        lda #$1b                                // switch charbank
                        sta $d011
                        lda #0                                  // set screen/border to black
                        sta $d020                               // border
                        sta $d021                               // screen
                        lda #%00000011
                        sta $dd00                               // Data Port A (Serial Bus, RS-232, VIC Memory Control)
                        jsr fillscreen                          // This sub routine clears the screen of any text
                                            
loop:                   jmp loop                                // no real time code so infinite loop
                
irq:                    
                        jsr topraster
                        jsr middleraster        
                        jsr bottomraster
                        inc $d019
                        jmp $ea31                               //end of IRQ
                        
                                                                // Startup Routines
                        
fillscreen:             ldx #0                                  // fill screen with " "
                        lda #$20
fillscrnlp:             sta $0400,x                             // Screen Location + X                      
                        sta $0500,x                             // Screen Location + X
                        sta $0600,x                             // Screen Location + X
                        sta $0700,x                             // Screen Location + X
                        cpx #255
                        inx
                        bne fillscrnlp  
                        ldx #0                                  // make everything white
                        lda #1
fillcolour:             sta $d800,x                             // Color RAM + X
                        sta $d900,x                             // Color RAM + X
                        sta $da00,x                             // Color RAM + X
                        sta $db00,x                             // Color RAM + X
                        inx
                        cpx #0
                        bne fillcolour          
                        rts

                        
topraster:              lda #$30
rast3:                  cmp $d012                               
                        bne rast3                               // Check if Raster/Write Raster is the same value as the accumulator <> waits                           
                        rts 
                                                                
middleraster:       
                        lda #$94
rast1:                  cmp $d012
                        bne rast1                               // Check if Raster/Write Raster is the same value as the accumulator <> waits                           
                        lda #$05
                        sta $d021                               // border colour change
                        sta $d020                               // screen colour change
                        rts 
                                                
bottomraster: 
                        lda #$20
rast2:                  cmp $d012
                        bne rast2                               // Check if Raster/Write Raster is the same value as the accumulator <> waits   
                        lda #$03                                
                        sta $d020                               // border colour change
                        sta $d021                               // screen colour change
                        rts 
			
			// revision 1.1 cleaned up comments a bit
