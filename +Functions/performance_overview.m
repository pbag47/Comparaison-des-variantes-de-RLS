function next_figure_number = performance_overview(Results, current_figure_number, save_figures, path)
    filtered_results = Functions.remove_NaN_results(Results) ;

    % Inventory of all studied noise types to get the number of figures to
    % create + inventory of all algorithms that have been tested for each
    % noise type
    Algorithms = fieldnames(Results) ;
    for ai = 1:length(Algorithms)
        Algorithm = Algorithms{ai} ;
        Noise_types = fieldnames(Results.(Algorithm)) ;
        for nti = 1:length(Noise_types)
            Noise = Noise_types{nti} ;
            try
                [~, index] = ismember({Noise}, {all_studied_noises{:, 1}}) ;
            catch Error
                switch Error.identifier
                    % Catches the 'Undefined Function' error for
                    % all_studied_noises which occurs at the very first
                    % iteration (ai = 1 & nti = 1)
                    case 'MATLAB:UndefinedFunction'
                        % Initializes the variable all_studied_noises
                        index = 0 ;
                        all_studied_noises = {} ;
                    otherwise
                        rethrow(Error)
                end
            end

            if index
                listed_algorithms = all_studied_noises{index, 2} ;
                listed_algorithms{length(listed_algorithms)+1} = Algorithm ;
                all_studied_noises{index, 2} = listed_algorithms ;
            else
                sz = size(all_studied_noises) ;
                all_studied_noises{sz(1) + 1, 1} = Noise ;
                all_studied_noises{sz(1) + 1, 2} = {Algorithm} ;
            end
        end
    end
    sz = size(all_studied_noises) ;
    next_figure_number = current_figure_number + sz(1) ;
    
    % Initialization of the variable that contains formatted results
    Overview = struct() ;
    
    sz = size(all_studied_noises) ;
    for nti = 1:sz(1)
        Noise = all_studied_noises{nti, 1} ;
        Algorithms = all_studied_noises{nti, 2} ;
        success_percentage = zeros(length(Algorithms), 1) ;
        minimum_convergence_time = zeros(length(Algorithms), 1) ;
        minimum_residuals = zeros(length(Algorithms), 1) ;
        median_convergence_time = zeros(length(Algorithms), 1) ;
        median_residuals = zeros(length(Algorithms), 1) ;
        for ai = 1:length(Algorithms)
            Algorithm = Algorithms{ai} ;
            % Number of total simulations for a given
            % algorithm and a given noise type
            sz = size(Results.(Algorithm).(Noise)) ;
            reference_number_of_simulations = sz(1) ;
            
            % Number of successful simulations for a given
            % algorithm and a given noise type
            sz = size(filtered_results.(Algorithm).(Noise)) ;
            number_of_successful_simulations = sz(1) ;

            success_percentage(ai) = round(number_of_successful_simulations / reference_number_of_simulations * 100) ;
            minimum_convergence_time(ai) = min(filtered_results.(Algorithm).(Noise).convergence) ;
            median_convergence_time(ai) = round(median(filtered_results.(Algorithm).(Noise).convergence)) ;
            minimum_residuals(ai) = min(filtered_results.(Algorithm).(Noise).residuals) ;
            median_residuals(ai) = median(filtered_results.(Algorithm).(Noise).residuals) ;
        end
        noise_results = table(success_percentage, minimum_convergence_time, median_convergence_time, ...
            minimum_residuals, median_residuals, 'RowNames', Algorithms) ;
        disp(Noise)
        disp(noise_results)
        Overview.(Noise) = noise_results ;
    end
end