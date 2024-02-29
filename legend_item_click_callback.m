function legend_item_click_callback(~, event)
    global graph_objects
    
    Noise_name = event.Peer.DisplayName ;
    Noise = strrep(Noise_name, ' ', '_') ;
    
    Algorithms = fieldnames(graph_objects) ;
    if strcmp(event.Peer.Visible,'on')
        for ai = 1:length(Algorithms)
            Algorithm = Algorithms{ai} ;
            if isfield(graph_objects.(Algorithm), Noise)
                graph_objects.(Algorithm).(Noise).convergence.line.Visible = 'off' ;
                graph_objects.(Algorithm).(Noise).convergence.scatter.Visible = 'off' ;
                graph_objects.(Algorithm).(Noise).residuals.line.Visible = 'off' ;
                graph_objects.(Algorithm).(Noise).residuals.scatter.Visible = 'off' ;
            end
        end
    else
        for ai = 1:length(Algorithms)
            Algorithm = Algorithms{ai} ;
            if isfield(graph_objects.(Algorithm), Noise)
                graph_objects.(Algorithm).(Noise).convergence.line.Visible = 'on' ;
                graph_objects.(Algorithm).(Noise).convergence.scatter.Visible = 'on' ;
                graph_objects.(Algorithm).(Noise).residuals.line.Visible = 'on' ;
                graph_objects.(Algorithm).(Noise).residuals.scatter.Visible = 'on' ;
            end
        end
    end
end
