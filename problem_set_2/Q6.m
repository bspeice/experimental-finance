clear;clc;
addpath('C:\Users\Helgi\Dropbox\Columbia\4736 Event Driven Finance\Projects\Project 2\');
file_path = 'C:\Users\Helgi\Dropbox\Columbia\4736 Event Driven Finance\Projects\Project 2\';
dates = {'2013-2-13', '2013-4-16', '2013-7-10'};
%dates = {'2006-2-8', '2006-4-12', '2006-7-10'};

% Get SQL queries
query_yield = fileread([file_path 'Q6_GetYield.sql']);
query_goog = fileread([file_path 'Q6_GetGOOG.sql']);
query_ibm = fileread([file_path 'Q6_GetIBM.sql']);
query_ibm_div = fileread([file_path 'Q6_GetIBM_Dividends.sql']);

% Connect to database
con_str = 'PROVIDER=SQLOLEDB; Data Source=vita.ieor.columbia.edu; initial catalog=XFDATA; User ID=IVYuser; password=resuyvi';
con = actxserver('ADODB.Connection');
con.CommandTimeout = 600; % Seconds
con.Open(con_str);

% Fetch data
yield_curves = cell2table(con.Execute(query_yield).GetRows()');
goog = cell2table(con.Execute(query_goog).GetRows()');
ibm = cell2table(con.Execute(query_ibm).GetRows()');
ibm_div = cell2table(con.Execute(query_ibm_div).GetRows()');

% Close database connection
con.Close();

% Parse yield data
yield_curves.Properties.VariableNames = {'Date','Days','Rate'};
yield_curves.Date = datetime(yield_curves.Date, 'InputFormat', 'dd-MMM-yy');

% Parse Google data
goog.Properties.VariableNames = {'Date','StockPrice','Expiration','ExpirationD','Strike','ATMdiff','CallPrice','CallIV','CallPOP','PutPrice','PutIV','PutPOP'};
goog.Date = datetime(goog.Date, 'InputFormat', 'dd-MMM-yy');
goog.Expiration = datetime(goog.Expiration, 'InputFormat', 'dd-MMM-yy');
goog.Strike = str2double(goog.Strike);
goog.CallPrice = str2double(goog.CallPrice);
goog.PutPrice = str2double(goog.PutPrice);

% Parse IBM data
ibm.Properties.VariableNames = {'Date','StockPrice','Expiration','ExpirationD','Strike','ATMdiff','CallPrice','CallIV','CallPOP','PutPrice','PutIV','PutPOP'};
ibm.Date = datetime(ibm.Date, 'InputFormat', 'dd-MMM-yy');
ibm.Expiration = datetime(ibm.Expiration, 'InputFormat', 'dd-MMM-yy');
ibm.Strike = str2double(ibm.Strike);
ibm.CallPrice = str2double(ibm.CallPrice);
ibm.PutPrice = str2double(ibm.PutPrice);

% Parse IBM dividend data
ibm_div.Properties.VariableNames = {'ExDivDate','DivAmount'};
ibm_div.ExDivDate = datetime(ibm_div.ExDivDate, 'InputFormat', 'dd-MMM-yy');


%% Analyze data
close all; clc;
BinomialTreeSteps = 100;

% Cycle through all dates
for i=1:length(dates)
    dt = datetime(dates{i},'InputFormat','yyyy-MM-dd');
    
    % Get IBM and Google option data
    goog_dat = goog(goog.Date==dt,:);
    ibm_dat = ibm(ibm.Date==dt,:);
    % Parse IBM dividend data
    ibm_div_dat = ibm_div(ibm_div.ExDivDate >= dt,:);
    ibm_div_dat.ExDivDate = (datenum(ibm_div_dat.ExDivDate) - datenum(dt))/360.0;
    
    % Google 
    goog_curve = [];
    goog_curve_dates = [];
    goog_expirations = unique(goog_dat.ExpirationD);
    goog_expirations = goog_expirations(goog_expirations > 7); % Skip expirations with time to maturity < 7 days
    % Cycle through expirations
    for j = 1:length(goog_expirations)
        goog_exp_dat = goog_dat(goog_dat.ExpirationD == goog_expirations(j),:); % Filter data
        
        % Get known parameters
        S0 = goog_exp_dat.StockPrice(1);
        DaysToMaturity = goog_expirations(j);
        T = double(DaysToMaturity) / 360.0;
        X = goog_exp_dat{:,'Strike'};
        call_price = goog_exp_dat{:,'CallPrice'};
        call_ivy_vol = goog_exp_dat{:,'CallIV'};
        call_pop = goog_exp_dat{:,'CallPOP'};
        put_price = goog_exp_dat{:,'PutPrice'};
        put_ivy_vol = goog_exp_dat{:,'PutIV'};
        put_pop = goog_exp_dat{:,'PutPOP'};
        
        % Initial guess for parameters
        % Interest rate guess from put call parity
        r_guess = max(double(mean((call_pop - put_pop) ./ (X .* T))), 0.0025); 
        % IV guess as mean of IVY vols
        sigma_guess = double(call_ivy_vol + put_ivy_vol) / 2;
        if (length(sigma_guess) < 5)
            sigma_guess = padarray(sigma_guess,5-length(sigma_guess),'post');
        end
        
        % Optimize parameters
        [PS,FVAL,EXITFLAG,OUTPUT] = fminsearch(...
            @(pars) Q6_ObjectiveFunction(call_price, put_price, S0, X, pars(1), T, BinomialTreeSteps, [], [], pars(2), pars(3), pars(4), pars(5), pars(6)), ...
            [r_guess; sigma_guess]);
        opt_r = PS(1);
        
        if (EXITFLAG ~= 1)
           disp('Optimization error'); 
        end
        
        goog_curve_dates(j) = DaysToMaturity;
        goog_curve(j) = opt_r;
    end
    
    % IBM 
    ibm_curve = [];
    ibm_curve_dates = [];
    ibm_expirations = unique(ibm_dat.ExpirationD);
    ibm_expirations = ibm_expirations(ibm_expirations > 7);     % Skip expirations with time to maturity < 7 days
    % Cycle through expirations
    for j = 1:length(ibm_expirations)
        ibm_exp_dat = ibm_dat(ibm_dat.ExpirationD == ibm_expirations(j),:); % Filter data
        
        % Get data
        S0 = ibm_exp_dat.StockPrice(1);
        DaysToMaturity = ibm_expirations(j);
        T = double(DaysToMaturity) / 360.0;
        X = ibm_exp_dat{:,'Strike'};
        call_price = ibm_exp_dat{:,'CallPrice'};
        call_ivy_vol = ibm_exp_dat{:,'CallIV'};
        call_pop = ibm_exp_dat{:,'CallPOP'};
        put_price = ibm_exp_dat{:,'PutPrice'};
        put_ivy_vol = ibm_exp_dat{:,'PutIV'};
        put_pop = ibm_exp_dat{:,'PutPOP'};
        
        % Initial guess for parameters
        % Interest rate guess from put call parity
        r_guess = max(double(mean((call_pop - put_pop) ./ (X .* T))), 0.0025); 
        % IV guess as mean of IVY vols
        sigma_guess = double(call_ivy_vol + put_ivy_vol) / 2;
        if (length(sigma_guess) < 5)
            sigma_guess = padarray(sigma_guess,5-length(sigma_guess),'post');
        end
        
        % Optimize parameters
        [PS,FVAL,EXITFLAG,OUTPUT] = fminsearch(...
            @(pars) Q6_ObjectiveFunction(call_price, put_price, S0, X, pars(1), T, BinomialTreeSteps, ibm_div_dat.DivAmount(ibm_div_dat.ExDivDate<=T), ibm_div_dat.ExDivDate(ibm_div_dat.ExDivDate<=T), ...
                                         pars(2), pars(3), pars(4), pars(5), pars(6)), ...
            [r_guess; sigma_guess]);
        opt_r = PS(1);
        
        if (EXITFLAG ~= 1)
           disp('Optimization error'); 
        end
        
        ibm_curve_dates(j) = DaysToMaturity;
        ibm_curve(j) = opt_r;
    end
    
    % Plot curves
    figure(i)
    plot(yield_curves.Days(yield_curves.Date==dt), yield_curves.Rate(yield_curves.Date==dt)/100,'k.-'); hold on;
    plot(goog_curve_dates, goog_curve,'r.-'); hold on;
    plot(ibm_curve_dates, ibm_curve,'b.-');
    title(datestr(dt));
    xlabel('Days to Maturity');
    ylabel('Rate'); ylim([0,0.02]);
    legend('Zero Curve','Google','IBM')
end