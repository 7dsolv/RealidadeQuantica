program tiny_anomalynet
  use iso_fortran_env, only: real32
  implicit none
  real(real32) :: w1(32,24), b1(24), w2(24,2), b2(2), x(32), h(24), logits(2)
  integer :: unit_in,unit_out,u,status,j
  character(len=2048) :: folder,input,output
  if(command_argument_count()/=3) error stop 'Use: tiny_anomalynet model_dir input.csv output.csv'
  call get_command_argument(1,folder)
  call get_command_argument(2,input)
  call get_command_argument(3,output)
  open(newunit=u,file=trim(folder)//'/fc1_weight.f32',access='stream',form='unformatted',status='old')
  read(u) w1; close(u)
  open(newunit=u,file=trim(folder)//'/fc1_bias.f32',access='stream',form='unformatted',status='old')
  read(u) b1; close(u)
  open(newunit=u,file=trim(folder)//'/fc2_weight.f32',access='stream',form='unformatted',status='old')
  read(u) w2; close(u)
  open(newunit=u,file=trim(folder)//'/fc2_bias.f32',access='stream',form='unformatted',status='old')
  read(u) b2; close(u)
  open(newunit=unit_in,file=trim(input),status='old',action='read')
  open(newunit=unit_out,file=trim(output),status='replace',action='write')
  do
    read(unit_in,*,iostat=status) x
    if(status<0) exit
    if(status/=0) error stop 'Invalid window'
    x=(x-50.0_real32)/20.0_real32
    do j=1,24
      h(j)=max(0.0_real32,dot_product(w1(:,j),x)+b1(j))
    end do
    do j=1,2
      logits(j)=dot_product(w2(:,j),h)+b2(j)
    end do
    write(unit_out,'(es24.15e3,a,es24.15e3)') logits(1),',',logits(2)
  end do
  close(unit_in); close(unit_out)
end program
