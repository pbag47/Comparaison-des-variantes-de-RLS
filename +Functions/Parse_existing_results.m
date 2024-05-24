function [Updated_parameters, add_counter] = Parse_existing_results(data_file_name, Parameters)
    add_counter = 0 ;
    Updated_parameters = struct() ;
    if isfile(data_file_name)
        empty_results_file = false ;
        disp(strcat('Parsing "', data_file_name, '"'))
        load(data_file_name, 'Results')
    else
        empty_results_file = true ; 
        warning('No data file found at provided path')
    end

    Algorithms = fieldnames(Parameters) ;
    for ai = 1:length(Algorithms)
        Algorithm = Algorithms{ai} ;
        header = strrep(Algorithm, '_', ' ') ;
        disp([header, ':'])
        Noise_types = fieldnames(Parameters.(Algorithm)) ;
        for nti = 1:length(Noise_types)
            Noise = Noise_types{nti} ;
            header = strrep(Noise, '_', ' ') ;
            disp(['  ', header, ':'])
            Variables = Parameters.(Algorithm).(Noise).Properties.VariableNames ;

            % Creates a cell array 'values', with 1 cell for each
            % variable. In these cells, every value that the variable
            % should take is listed.
            values = cell(1, length(Variables)) ;
            for vi = 1:length(Variables)
                Variable = Variables{vi} ;
                values{vi} = Parameters.(Algorithm).(Noise).(Variable) ;
            end

            % From 'values', every possible combination of every
            % variable value is listed as the rows of a matrix
            % 'combinations_to_add'
            combinations = combvec(values{:}) ;

            % This matrix is then refactored as a table with the
            % corresponding variable name
            table_of_combinations = array2table(transpose(combinations), ...
                'VariableNames', Variables) ;

            % If no previous simulation results are found, the
            % paramters are given by 'table_of_combinations'.
            if ~empty_results_file
                % If previous simulation results exist, then a comparison
                % between 'table_of_combinations' and these results is
                % performed to remove the duplicates.
                index_of_duplicates = ismember(table_of_combinations, Results.(Algorithm).(Noise)(:, Variables)) ;
                table_of_combinations(index_of_duplicates, :) = [] ;
                disp(['    ', num2str(length(index_of_duplicates)), ' simulations discarded (previous results found in ', data_file_name, ')'])
            end
            sz = size(table_of_combinations) ;
            add_counter = add_counter + sz(1) ;
            disp(['    ', num2str(sz(1)), ' simulations added'])
            Updated_parameters.(Algorithm).(Noise) = table_of_combinations ;
        end
    end
end