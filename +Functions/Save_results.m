function Save_results(data_file_name, Results_to_save)
    if isfile(data_file_name)

        % Merge new results struct with previous results
        load(data_file_name, 'Results') ;
        
        Algorithms = fieldnames(Results_to_save) ;
        for ai = 1:length(Algorithms)
            Algorithm = Algorithms{ai} ;
            Noise_types = fieldnames(Results_to_save.(Algorithm)) ;
            for nti = 1:length(Noise_types)
                Noise = Noise_types{nti} ;
                try
                    Results_column_names = Results.(Algorithm).(Noise).Properties.VariableNames ;
                    Results_to_save_column_names = Results_to_save.(Algorithm).(Noise).Properties.VariableNames ;

                    assert(isequal(intersect(Results_column_names, Results_to_save_column_names), ...
                            union(Results_column_names, Results_to_save_column_names)), ...
                            'RESULTS:incompatibleColumnNames', ...
                            ['Unable to merge newest results to already existing results file: Table entries mismatch. \n', ...
                            'Make sure that the variables names in "Parameters" remain the same accross simulation batches'])

                    Results.(Algorithm).(Noise) = [Results.(Algorithm).(Noise) ; Results_to_save.(Algorithm).(Noise)] ;
                catch Error
                    switch Error.identifier
                        case 'MATLAB:nonExistentField'
                            disp([' -- Warning -- No previous results found for ', Algorithm, ' -> ', Noise, ' in file ', data_file_name])
                            disp('               Creating a new storage location')
                            Results.(Algorithm).(Noise) = Results_to_save.(Algorithm).(Noise) ;
                        otherwise 
                            rethrow(Error) ;
                    end
                end
            end
        end

        % Sort the results to a parameter-ascending order
        % Results = Functions.Sort_results(Results) ;
        
        % Save
        save(data_file_name, 'Results')
        disp('Data saved')
    else
        warning('No data file found at provided path, creating a new file to save data...')
        Results = Results_to_save ;
        save(data_file_name, 'Results')
        disp('File created, data saved')
    end
end