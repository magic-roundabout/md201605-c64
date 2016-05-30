;
; md201605 :: FINAL LINKER
;

; This just loads the compressed file and removes $d030 writes and a CLI from
; the PuCrunch decruncher. This doesn't NEED to be done, but it makes the final
; release a little prettier at least to my mind.

; This will generate "segment starts" errors from ACME when assembled!


; Select an output filename
		!to "md201605_link.prg",cbm


; Yank in binary data
		* = $0801
		!binary "md201605_pu.prg",,2


; Cheap and cheerful patches to the crunched binary
; Remove $D030 writes
		* = $080e
		nop
		nop
		nop

		* = $092c
		nop
		nop
		nop

; Remove CLI
		* = $0937
		nop
