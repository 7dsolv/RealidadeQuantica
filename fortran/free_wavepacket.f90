program free_wavepacket
    use iso_fortran_env, only: real64
    implicit none

    integer, parameter :: point_count = 1001
    integer :: point, output_unit, io_status
    real(real64) :: sigma_0, k_0, time, x, pi_value, probability
    complex(real64) :: spread_factor, phase_exponent, psi
    character(len=128) :: argument
    character(len=1024) :: output_path

    if (command_argument_count() < 4) then
        error stop 'Uso: free_wavepacket sigma_0 k_0 time arquivo_saida'
    end if

    call get_command_argument(1, argument)
    read(argument, *) sigma_0
    call get_command_argument(2, argument)
    read(argument, *) k_0
    call get_command_argument(3, argument)
    read(argument, *) time
    call get_command_argument(4, output_path)

    if (sigma_0 <= 0.0_real64) error stop 'sigma_0 precisa ser positivo.'

    pi_value = acos(-1.0_real64)
    spread_factor = cmplx(1.0_real64, time / (2.0_real64 * sigma_0**2), kind=real64)
    open(newunit=output_unit, file=trim(output_path), status='replace', &
        action='write', iostat=io_status)
    if (io_status /= 0) error stop 'Nao foi possivel criar o arquivo de saida.'

    do point = 1, point_count
        x = -10.0_real64 + 20.0_real64 * real(point - 1, real64) &
            / real(point_count - 1, real64)
        phase_exponent = -cmplx((x - k_0 * time)**2, 0.0_real64, kind=real64) &
            / (4.0_real64 * sigma_0**2 * spread_factor) &
            + cmplx(0.0_real64, k_0 * x - 0.5_real64 * k_0**2 * time, kind=real64)
        psi = (2.0_real64 * pi_value * sigma_0**2)**(-0.25_real64) &
            * exp(phase_exponent) / sqrt(spread_factor)
        probability = abs(psi)**2
        write(output_unit, '(3(ES25.16,1X))') x, real(psi, real64), probability
    end do

    close(output_unit)
end program free_wavepacket
