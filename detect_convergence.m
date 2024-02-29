function [Has_converged, number_of_iterations] = detect_convergence(Error_RMS, ...
    residuals, divergence_threshold, maximum_allowed_convergence_time)
    
    Has_converged = true ;
    number_of_iterations = NaN ;
    
    %% Divergence detection
    if residuals > divergence_threshold || residuals == 0
        disp(['    Divergence detected, too high residuals (', num2str(residuals), ')'])
        Has_converged = false ;
        return
    end
    
    %% Convergence detection
    % Finds the first Error_RMS sample whose value is lower than the residuals
    for k = 1:maximum_allowed_convergence_time
        if Error_RMS(k) < residuals
            Has_converged = true ;
            number_of_iterations = k ;
            return
        end
    end
    
    if isnan(number_of_iterations)
        disp('    Too slow convergence -> unusable results')
        Has_converged = false ;
        return
    end
end

