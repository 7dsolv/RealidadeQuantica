program xeno_optics_reference
  ! Referencia independente, matrizes 2x2 complexas, incidencia normal.
  use iso_fortran_env, only: real64
  implicit none
  integer :: i, layer, unit_out
  real(real64) :: w, phase, nh, nl, dh, dl, n0, ns, index_n, thick
  real(real64) :: reflectance, transmittance, pi
  complex(real64) :: matrix(2,2), slab(2,2), denominator, rr, tt
  character(len=1024) :: output
  if (command_argument_count() /= 1) error stop 'Use: xeno_optics_reference output.csv'
  call get_command_argument(1, output)
  open(newunit=unit_out,file=trim(output),status='replace',action='write')
  write(unit_out,'(a)') 'wavelength_nm,R,T'
  pi = acos(-1.0_real64)
  n0 = 1.0_real64; ns = 1.5_real64
  nh = 1.65_real64 - 0.08_real64*0.4_real64; nl = 1.34_real64
  dh = 470.0_real64/(4*1.65_real64)*(1+0.32_real64*0.4_real64)*(1-0.7_real64*0.03_real64)
  dl = 470.0_real64/(4*nl)*(1+0.16_real64*0.4_real64)*(1-0.3_real64*0.03_real64)
  do i=0,200
    w = 380.0_real64+2*i
    matrix = cmplx(0.0_real64,0.0_real64,real64)
    matrix(1,1)=1; matrix(2,2)=1
    do layer=1,12
      if (mod(layer,2)==1) then
        index_n=nh; thick=dh
      else
        index_n=nl; thick=dl
      end if
      phase = 2*pi*index_n*thick/w
      slab(1,1)=cos(phase); slab(2,2)=cos(phase)
      slab(1,2)=cmplx(0.0_real64,sin(phase)/index_n,real64)
      slab(2,1)=cmplx(0.0_real64,sin(phase)*index_n,real64)
      matrix=matmul(matrix,slab)
    end do
    denominator=n0*matrix(1,1)+n0*ns*matrix(1,2)+matrix(2,1)+ns*matrix(2,2)
    rr=(n0*matrix(1,1)+n0*ns*matrix(1,2)-matrix(2,1)-ns*matrix(2,2))/denominator
    tt=2*n0/denominator
    reflectance=abs(rr)**2; transmittance=ns/n0*abs(tt)**2
    if (abs(reflectance+transmittance-1)>1e-12_real64) error stop 'Optical balance failed'
    write(unit_out,'(f10.3,2(a,es25.16e3))') w,',',reflectance,',',transmittance
  end do
  close(unit_out)
  print '(a)', 'Fortran X-01: 201 comprimentos de onda, balanco R+T aprovado.'
end program
