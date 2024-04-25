function [Error, t] = DWTLMS_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    assert(0 < filter_length && filter_length <= 90 && floor(filter_length/2) == filter_length/2)

    %% Initialization
    beta_Lambda = variables(1) ;
    theta_DWT = variables(2)  ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(filter_length, 1) ;
    H_DWT = zeros(filter_length, 1) ;
    DWT_matrix = zeros(filter_length) ;
    Lambda_DWT = 10*eye(filter_length) ;

    %% DWT matrix build-up
    DWT_matrix(1, :) = 1/sqrt(filter_length) * ones(1, filter_length) ;
    number_of_scales = log2(filter_length) ;
    current_vector_number = 1 ;
    for i = number_of_scales:-1:1
        scale_size = 2^i ;
        vect = zeros(1, filter_length) ;
        vect(1:scale_size/2) = ones(1, scale_size/2) ;
        vect(scale_size/2+1:scale_size) = -ones(1, scale_size/2) ;
        vect = vect ./ sqrt(vect*transpose(vect)) ;
        number_of_vectors = 2^(number_of_scales-i) ;
        for j = 1:number_of_vectors
            DWT_matrix(current_vector_number+j, :) = circshift(vect, (j-1)*filter_length/number_of_vectors) ;
        end
        current_vector_number = current_vector_number + number_of_vectors ;
    end

    %% DWTLMS algorithm based on Haar wavelet (also called D2 Daubechies wavelet)
    % DWT_matrix^-1 = transpose(DWT_matrix)
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) ; X(1:filter_length-1)] ;
        X_DWT = DWT_matrix * X ;
        Lambda_DWT = diag(diag( (1-beta_Lambda) * X_DWT * transpose(X_DWT) + beta_Lambda * Lambda_DWT)) ;
        Error(i) = Expected_result(i) - transpose(H_DWT) * X_DWT ;
        H_DWT = H_DWT + theta_DWT/filter_length * Error(i) * Lambda_DWT^(-1) * X_DWT ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm run-time : ', num2str(t), ' s'])
end