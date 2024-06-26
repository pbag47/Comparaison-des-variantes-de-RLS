___
# Project: Comparaison des variantes de RLS

This project is a simulation environment made to benchmark different Least Squares algorithms in terms of convergence time and residual error, for various input signals.

It is supported on Matlab version R2023b or later.

___
## File dependency analysis

![Dependency analysis](https://github.com/pbag47/Comparaison-des-variantes-de-RLS/blob/Generalized_TDLMS/Dependency%20Graph.png)

___
## Operating mode

The main executable file is `main.m`. 
This file contains the configurable settings and calls several functions by following the procedure in the table below. 

| File                                                                        | Description |
| --------------------------------------------------------------------------- | ----------- |
| `main.m`                                                                    | First, the program makes a list of every simulation request (each noise type, each algorithm, each variable), according to the parameters set by the user. |
| `+Functions\Parse_existing_results.m`                                       | Then, the previous simulation results are inspected to make sure that the exact same simulation is not ran twice. If a requested simulation already exists in the previous results file, this simulation request is automatically discarded. |
| `+Functions\Algorithm_test.m`                                               | Then, a testing procedure starts: <br> For each requested noise type, the program counts the requested algorithms <br> <ul> For each algorithm, the program searches for all the possible combinations of requested values for its tuning parameters <br> <ul> For each combination of values, the selected algorithm is executed with an input signal that corresponds to the selected noise type, and a constant desired impulse response. </ul> </ul> |
| `+Functions\detect_convergence.m`                                           | <ul> <ul> Then, the convergence time and the residual error are deduced from the error RMS curve. </ul> </ul> |
| `+Functions\remove_NaN_results.m` <br> `+Functions\save_results.m`          | The results are finally filtered and saved as a _struct_ variable in a file set by the user. |
| `+Functions\compare_algorithmsn.m` <br> `+Functions\performance_overview.m` | Once this testing procedure is finished, the results are displayed as graph figures and tables. |

___
## Settings

### Default available input noises

| Name | Description |
| --- | --- |
| 'White_noise' | White random Gaussian noise of mean $0$ and power $1$. <br> Eigenvalue spread of the sample-estimate autocorrelation matrix: $0.1359$ |
| 'Pink_noise' | Pink random noise of mean $0$ and power $1$. <br> Eigenvalue spread of the sample-estimate autocorrelation matrix: $17.92$ |
| 'Brownian_noise' | Brownian random noise of mean $0$ and power $1$. <br> Eigenvalue spread of the sample-estimate autocorrelation matrix: $31.75$ |
| 'Tonal_input' | Sinusoïd of mean $0$, amplitude $\sqrt{2}$ and frequency $200Hz$ sampled at $22050Hz$ |
| 'UAV_noise' | Audio from the Youtube video ![https://www.youtube.com/watch?v=lsCu03bnWJ0](https://www.youtube.com/watch?v=lsCu03bnWJ0) <br> from timestamps $3:44$ to $3:45$, downsampled via linear interpolation from $48000Hz$ to $22050Hz$, and normalized to a unitary power. <br> Eigenvalue spread of the sample-estimate autocorrelation matrix: $7.540$ |

### Variables

| Variable | Type hint: Default value | Description | Additionnal information |
| --- | --- | --- | --- |
| `filter_length` | int: 32 | Number of taps that define the impulse response of the adaptive FIR filter | Must be an integer power of 2 |
| `data_file` | str: '+Results/test.mat' | File in which the simulation results are stored (automatically created if the file does not exist) | Must terminate by '.mat' <br> By default, all results files are stored in the __+Results__ package sub-folder |
| `save_figures` | bool: true | Automatically save the generated figures as .fig and .pdf files |  |
| `plot_all_error_curves` | bool: false | Display the error curve obtained after each simulation | Only for debug purposes |
| `noise_types` | cell: {'White_noise'} | Select which input noise to use as a reference signal for the algorithms | Choose one or more elements from the following list: <br> - 'White_noise' <br> - 'Pink_noise' <br> - 'Brownian_noise' <br> - 'Tonal_input' <br> - 'UAV_noise' |

### Requesting algorithm tests

In `main.m`, the variable that contains requested simulation settings is called `Parameters`.
This variable is a structure organized as described by the following example picture:
![Structure of Parameters variable](https://github.com/pbag47/Comparaison-des-variantes-de-RLS/blob/Generalized_TDLMS/Parameters_structure_graph.png)

For this example, the simulation environment is configured to run 6 different simulations, whose settings are summarized in the next table.

| Algorithm | Noise type  | Name of variable 1 | Value of variable 1 | Name of variable 2 | Value of variable 2 |
| --------- | ----------- | -----------------: | :------------------ | -----------------: | :------------------ |
| RLS       | White_noise | lambda             | 0.9                 |        //          |         //          |
| DWTLMS    | White_noise | beta               | 0.1                 | theta              | 0.7                 |
| DWTLMS    | White_noise | beta               | 0.2                 | theta              | 0.7                 |
| DWTLMS    | Pink_noise  | beta               | 0.4                 | theta              | 0.5                 |
| DWTLMS    | Pink_noise  | beta               | 0.4                 | theta              | 0.8                 |
| DCTLMS    | UAV_noise   | beta               | 0.6                 | theta              | 0.9                 |

In terms of Matlab code, this simulation request is implemented in `main.m` as follows:
```matlab
Parameters.RLS.White_noise.lambda = 0.9 ;

Parameters.DWTLMS.White_noise.beta = [0.1, 0.2] ;
Parameters.DWTLMS.White_noise.theta = 0.7 ;

Parameters.DWTLMS.Pink_noise.beta = 0.4 ;
Parameters.DWTLMS.Pink_noise.theta = [0.5, 0.8] ;

Parameters.DCTLMS.UAV_noise.beta = 0.6 ;
Parameters.DCTLMS.UAV_noise.theta = 0.9 ;
```

If the results are stored in a file and gradually added, the noise types, algorithms and variable names have to remain consistent with the already existing results.

The `Parameters` structure can remain empty. In this case, no simulation is run but the results found in the file provided by `data_file` are displayed.

___

## Adding new reference signals

The signals used as a reference to test the algorithms are stored in the file `Noise_samples.mat`.
To append a new usable signal, supposedly called 'Signal_name' and stored as the variable `s` in Matlab Workspace, run the following code in the Command Window:

```Matlab
load('Noise_samples.mat')
Noise_samples.Signal_name = s ;
save('Noise_samples.mat', "Noise_samples')
```

To verify that the new signal has successfully been imported, run the file `plot_input_signals.m` and make sure that it is correctly displayed and named in the resulting figure.

Then, this new signal can be called from the `main.m` as a reference signal to test algorithms, see Part "Requesting algorithm tests".

___


