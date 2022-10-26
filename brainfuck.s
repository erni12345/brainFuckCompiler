.global brainfuck


#TODO : MAKE THE CODE BLOCK EXECUTABLE + FIX THE END LOOP

charPrint: .asciz "%c"
format_str: .asciz "We should be executing the following code:\n%s"
input: .asciz "%c"
debug: .asciz "PLEASE WORK %d \n"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp
  
  
  call compile
  
  pushq %rax

  movq $32768, %rdi
  call malloc
  movq %rax, %rdi
  popq %r10
  
  jmp *%r10
  movq $0, %rdi

  movq %rbp, %rsp
  popq %rbp
  ret

  call exit




#Allocate memory for the instructions
compile:
  
  #Prologue
  pushq %rbp
  movq %rsp, %rbp

  #Store registers to set them back to what they were
  pushq %r12
  pushq %r15
  pushq %r14
  pushq %r13

  movq %rdi, %r15
  movq $0, %r14
  
  #Create space and map to use like an array[] for the instructions using
  # mmap() c function. args : ( *address, length, protect, flags, filedes, offset)
  movq $0, %rdi # *address
  shl $4, %rsi # shift left by 4 bits so that we can allocate 8 bytes per character/command/instruction
  movq $6, %rdx #Protection : Read and Write
  movq $0x22, %rcx #mapping flag
  movq $-1, %r8 #no dile descriptor
  movq $0, %r9 #0 offset we want to start at the beggining
  call mmap

  movq %rax, %r13  # address of first memory space
  pushq %r13

  


prologueMaker:
  
  addq $1, %r13
  movq $0x5de58b48, (%r13)
  addq $4, %r13
  movq $0x55, (%r13) #pushq %rbp
  addq $1, %r13
  movq $0x4889E5, (%r13) #movq %rsp, %rbp
  addq $3, %r13
  movq $0x4157, (%r13) #pushq %r15
  addq $2, %r13
  movq $0x4156, (%r13) #pushq %r14
  addq $2, %r13
  movq $0x4989ff, (%r13)  #movq %rdi, %r15
  addq $3, %r13
  movq $0x49c7c6, (%r13)    #movq $0, %r14
  addq $10, %r13


#Loads the next instruction/character/command into %dil (rdi) 1 byte
parsingLoop:

  
  movb (%r15, %r14), %dil
#Parsing switch logic, we check what character we are dealing with
  # Check for different possible cases, ignore if not part of the cases. 
  cmpb $0, %dil           
  je endOfParsing     
  cmpb $46, %dil          # "." Print character
  je printChar
  cmpb $44, %dil          # "," Get character 
  je getChar
  cmpb $43, %dil          # "+" Increase value at a ddress
  je incrVal
  cmpb $45, %dil          # "-" Decrease value at address 
  je decrVal
  cmpb $91, %dil          # "[" Set up looping point 
  je loopStart
  cmpb $93, %dil          # "]" Jump back to looping point 
  je loopEnd
  cmpb $60, %dil          # "<" Decrease address pointer 
  je prevAddr
  cmpb $62, %dil          # ">" Increase address pointer 
  je nextAddr
  
  incq %r14
  jmp parsingLoop


printChar:

  incq %r14  #increment our instruction pointer

  movq $0x4b8d3437, (%r13) #leaq(%r15, %r14, 1), %rsi
  addq $4, %r13
  movq $0xBA49, (%r13) #movq $printCharFunc, %r10
  addq $2, %r13
  movq $charPrint, (%r13)
  addq $3, %r13
  movq $0xD2FF41, (%r13)  #call *%r10
  addq $3, %r13

  jmp parsingLoop


getChar:
  
  

  movq $0x373c8d4b, (%r13)
  addq $4, %r13
  movq $0xBA49, (%r13) #movq $getCharFunc, %r10
  addq $2, %r13
  movq $getCharFunc, (%r13)
  addq $8, %r13
  movq $0xD2FF41, (%r13) #call *%r10
  addq $3, %r13
  
  incq %r14 #increment our instruction pointer
  jmp parsingLoop


incrVal:
  


  movq $0x43fe0437, (%r13)  #incb (%r15, %r14, 1)
  addq $4, %r13

  incq %r14  
  jmp parsingLoop

decrVal:
  

  movq $0x43fe0c37, (%r13) #decb, (%r15, %r14, 1)
  addq $4, %r13

  incq %r14
  jmp parsingLoop

  
loopStart:
  
  incq %r14

  movq $0x4156, (%r13) #push r14 (so we know where to go back later)
  jmp parsingLoop


loopEnd:
  movq $0x415c, (%r13) #pop %r12
  movq $0x43803c37, (%r13) #cmpb $0, (%r15, %r14, 1)
  addq $5, %r13
  movq $0x0f85, (%r13) #jne begin (begin will now be calculated)
  addq $2, (%r13)
  
  

  incq %r14
  jmp parsingLoop

 
prevAddr:

  incq %r14

  movq $0xceff49, (%r13) #decq %r14
  addq $5, %r13
  jmp parsingLoop


nextAddr:
  incq %r14
  movq $0xc6ff49, (%r13) #incq %r14
  addq $5, %r13
  jmp parsingLoop


endOfParsing:
  

  #retrun registers that are used to what they used to be
  movq $0x5f415e41, (%r13) #popq r14 - r15
  addq $4, %r13
  movq $0x5de58b48, (%r13)
  addq $4, %r13
  movq $0xc3, (%r13)
  addq $1, %r13
  popq %r12   #first address of memory
  
  
  movq %r13, %rsi
  subq %r12, %rsi
  mov %r12, %rdi
  mov $4, %rdx
  call mprotect

  
  popq %r13
  popq %r14
  popq %r15
  
  movq %r12, %rax
  popq %r12

  #Epilogue
  movq %rbp, %rsp
  popq %rbp
  ret











printCharFunc:
  movq %rdi, %rsi
  movq $charPrint, %rdi
  call printf
  ret


getCharFunc:
  
  push %rdi

  subq $16, %rsp
	movq $0, %rax
	movq $input, %rdi
	leaq -8(%rbp), %rsi    
	call scanf
  
  addq $8, %rsp
  pop %rdi
  movb %dil, (%r15, %r14, 1)

  pop %rdi

  ret


  
  
