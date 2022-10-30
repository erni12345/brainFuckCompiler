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

  movq $100000, %rdi
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
  
  mov $0xEC894855, (%r13) #mov %rbp, %rsp + pushq %rbp
  addq $4, %r13
  movq $0x5741, (%r13) #pushq %r15
  addq $2, %r13
  movq $0x5641, (%r13) #pushq %r14
  addq $2, %r13
  movq $0xff8949, (%r13)  #movq %rdi, %r15
  addq $3, %r13
  movq $0x00e68349, (%r13) #and $0, %r14 
  addq $4, %r13

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
  movq $0x00e68348, (%r13) #and $0, %rsi
  addq $4, %r13
  movq $0x37348a43, (%r13) #movb (%r15, %r14, 1), %sil
  addq $4, %r13
  movq $0xBA49, (%r13)    #movq $$printCharFunc, %r10
  addq $2, %r13
  movq $printCharFunc, (%r13)
  addq $8, %r13
  movq $0xD2FF41, (%r13)      #call *%r10
  addq $3, %r13

  
  jmp parsingLoop


getChar:
  
  
  movq $0xBA49, (%r13) #movq $getCharFunc, %r10
  addq $2, %r13
  movq $getCharFunc, (%r13) 
  addq $8, %r13
  movq $0xD2FF41, (%r13) #call *%r10
  addq $3, %r13
  
  incq %r14 #increment our instruction pointer
  jmp parsingLoop


incrVal:
  


  movq $0x3704ff43, (%r13)  #incb (%r15, %r14, 1)
  addq $4, %r13
  incq %r14  
  jmp parsingLoop

decrVal:
  

  movq $0x370cfe43, (%r13) #decb, (%r15, %r14, 1)
  addq $4, %r13

  incq %r14
  jmp parsingLoop

  
loopStart:
  cmpw $0x5d3d, 1(%r15, %r14, 1)
  jne zeroing
  
  movq $0x003704c74b, (%r13)
  addq $5, %r13
  addq $3, %r14
  jmp parsingLoop


zeroing:
  pushq %r13
  mov $0x00373c8043, (%r13)
  addq $5, %r13
  movq $0x840f, (%r13)
  addq $6, %r13
  incq %r14
  jmp parsingLoop



loopEnd:

    mov $0x00373c8043, (%r13)
    addq $5, %r13
    movq $0x850f, (%r13)    #jne begin
    addq $2, %r13

    popq %r12
    movq %r13, %rax
    subq %r12, %rax
    subq $7, %rax
    mov %eax, 7(%r12)
    negq %rax
    mov %eax, (%r13)
    addq $4, %r13
    incq %r14
    jmp parsingLoop

  

 
prevAddr:

  incq %r14

  movq $0xceff49, (%r13) #decq %r14
  addq $3, %r13
  jmp parsingLoop


nextAddr:
  incq %r14
  movq $0xc6ff49, (%r13) #incq %r14
  addq $3, %r13
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

  pushq %rbp
  movq %rsp, %rbp
  movq $0, %rax
  movq $charPrint, %rdi
  call printf
  movq %rbp, %rsp
  popq %rbp
  ret


getCharFunc:
   
  push %rbp
  mov %rsp, %rbp

  push %rdi
  
  subq $8, %rsp
	movq $0, %rax
	movq $input, %rdi
	leaq -8(%rbp), %rsi    
	call scanf
  movq -8(%rbp), %rdi
  movb %dil, (%r15, %r14, 1)
  
  addq $8, %rsp
  pop %rdi

  mov %rbp, %rsp
  pop %rbp

  ret



  
  
