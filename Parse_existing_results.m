function [Updated_parameters, tests_added] = Parse_existing_results(data_file_name, Parameters)
    tests_added = false ;
    Updated_parameters = struct() ;
    
    % Parse previous simulations results and fill 'Updated_parameters' 
    % struct only with parameter combinations that do not already exist
    Noise_types = fieldnames(Parameters) ;
    disp(strcat('Parsing "', data_file_name, '"'))
    if isfile(data_file_name)
        load(data_file_name, 'Results')
        for nti = 1:length(Noise_types)
            Noise_type = Noise_types{nti} ;
            Updated_parameters.(Noise_type) = struct() ;
            header = strrep(Noise_type, '_', ' ') ;
            disp(['  ', header, ':'])
            
            Algorithms = fieldnames(Parameters.(Noise_type)) ;
            for ai = 1:length(Algorithms)
                Algorithm = Algorithms{ai} ;
                Updated_parameters.(Noise_type).(Algorithm) = struct() ;
                add_counter = 0 ;
                Variables = fieldnames(Parameters.(Noise_type).(Algorithm)) ;
                number_of_combinations_in_file = length(Results.(Noise_type).(Algorithm).(Variables{1})) ;
                combinations_in_file = zeros(length(Variables), number_of_combinations_in_file) ;
                checked_values = cell(1, length(Variables)) ;
                header = strrep(Algorithm, '_', ' ') ;
                header = [header, ', Variables:'] ;
                for vi = 1:length(Variables)
                    Variable = Variables{vi} ;
                    Updated_parameters.(Noise_type).(Algorithm).(Variable) = [] ;
                    header = [header, ' [', Variable, ']'] ;
                    checked_values{vi} = Parameters.(Noise_type).(Algorithm).(Variable) ;
                    combinations_in_file(vi, :) = Results.(Noise_type).(Algorithm).(Variable) ;
                end
                combinations_to_check = combvec(checked_values{:}) ;
                disp(['    ', header])
                
                for ic = 1:length(combinations_to_check) % ivsv: Index of Combination to check
                    try
                        if ~any(ismember(combinations_to_check(:, ic)', combinations_in_file', 'rows'))
                            add_counter = add_counter + 1 ;
                            tests_added = true ;
                            for vi = 1:length(Variables)
                                Variable = Variables{vi} ;
                                Updated_parameters.(Noise_type).(Algorithm).(Variable) = [Updated_parameters.(Noise_type).(Algorithm).(Variable),...
                                    combinations_to_check(vi, ic)] ;
                            end
                        end
                    catch Error
                        if strcmp(Error.identifier, 'MATLAB:nonExistentField')
                            disp(['  ', 'New algorithm description detected, adding ',...
                                  Noise_type, ' -> ', Algorithm])
                            tests_added = true ;
                            for vi = 1:length(Variables)
                                Variable = Variables{vi} ;
                                Updated_parameters.(Noise_type).(Algorithm).(Variable) = combinations_to_check(vi, :) ;
                            end
                            break
                        else
                            throw(Error)
                        end
                    end
                end
                disp(['      ', num2str(length(combinations_to_check)-add_counter), ' simulations discarded (previous results found in ', data_file_name, ')'])
                disp(['      ', num2str(add_counter), ' simulations remaining'])
            end
        end
    else
        disp(' ---- Warning ---- No data file found at provided path')
        tests_added = true ;
        for nti = 1:length(Noise_types)
            Noise_type = Noise_types{nti} ;
            header = strrep(Noise_type, '_', ' ') ;
            disp([header, ':'])
            
            Algorithms = fieldnames(Parameters.(Noise_type)) ;
            for ai = 1:length(Algorithms)
                Algorithm = Algorithms{ai} ;
                Variables = fieldnames(Parameters.(Noise_type).(Algorithm)) ;
                
                values = cell(1, length(Variables)) ;
                for vi = 1:length(Variables)
                    Variable = Variables{vi} ;
                    values{vi} = Parameters.(Noise_type).(Algorithm).(Variable) ;
                end
                combinations_to_add = combvec(values{:}) ;
                for vi = 1:length(Variables)
                    Variable = Variables{vi} ;
                    Updated_parameters.(Noise_type).(Algorithm).(Variable) = combinations_to_add(vi, :) ;
                end
            end
        end
    end
end