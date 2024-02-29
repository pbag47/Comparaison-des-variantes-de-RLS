function Save_results(data_file_name, Results_to_save)
    if isfile(data_file_name)
        
        % Merge new results struct with previous results
        load(data_file_name, 'Results') ;
        Noise_types = fieldnames(Results_to_save) ;
        for nti = 1:length(Noise_types)
            Noise = Noise_types{nti} ;
            Algorithms = fieldnames(Results_to_save.(Noise)) ;
            for ai = 1:length(Algorithms)
                Algorithm = Algorithms{ai} ;
                try
                    fields = fieldnames(Results.(Noise).(Algorithm)) ;
                catch
                    % Allows the creation of storage locations for
                    % newly encountered variables, if simulation
                    % results are available
                    fields = fieldnames(Results_to_save.(Noise).(Algorithm)) ;
                    if any(strcmp(fields, 'convergence'))
                        for fi = 1:length(fields) % fi: Field Index
                            field = fields{fi} ;
                            Results.(Noise).(Algorithm).(field) = [] ;
                        end
                    end
                end
                for fi = 1:length(fields)
                    field = fields{fi} ;
                    for si = 1:length(Results_to_save.(Noise).(Algorithm).(field))
                        Results.(Noise).(Algorithm).(field) = [Results.(Noise).(Algorithm).(field),...
                            Results_to_save.(Noise).(Algorithm).(field)(si)] ;
                    end
                end
            end
        end
        
        % Sort the results to a parameter-ascending order
        Results = Sort_results(Results) ;
        
        % Save
        save(data_file_name, 'Results')
        disp('Data saved')
    else
        disp(' ---- Warning ---- No data file found at provided path, creating a new file to save data...')
        Results = Results_to_save ;
        save(data_file_name, 'Results')
        disp('File created, data saved')
    end
end