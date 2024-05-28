function Results = remove_NaN_results(Results)
    disp('Filtering results:')
    Algorithms = fieldnames(Results) ;
    for ai = 1:length(Algorithms)
        Algorithm = Algorithms{ai} ;
        Noise_types = fieldnames(Results.(Algorithm)) ;
        for nti = 1:length(Noise_types)
            Noise = Noise_types{nti} ;
            nan_occurances = isnan(Results.(Algorithm).(Noise).computing_time) ;
            number_of_nan = sum(nan_occurances) ;
    
            disp(['  ', Algorithm, ' | ', Noise, ' | ', num2str(number_of_nan), ' NaN results found. ', ...
                ' Total: ', num2str(length(Results.(Algorithm).(Noise).convergence)), ' simulations'])
            
            for oi = length(nan_occurances):-1:1
                if nan_occurances(oi)
                    Results.(Algorithm).(Noise)(oi, :) = [] ;
                end
            end
        end
    end
end
