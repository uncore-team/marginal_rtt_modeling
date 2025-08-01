function [y,w] = weld_functions(funparts,transpoints,kperc,x)
% Weld a number of functions smoothly with a sigmoid weight profile for
% each pair of them and evaluate the result at a given point. 
%
% FUNPARTS -> a cell with as many number as functions to weld at their
%             extremes (the first one and the last one are only welded to
%             another; the rest are welded to one at each extreme). The
%             functions are assumed to be valid from X = 0 to X =
%             TRANSPOINTS(end); if X is <= 0, the first function will be
%             used only; if X is > TRANSPOINTS(end), the last function will
%             be used only. This sequence of functions forms a
%             partition in the X axis.
% TRANSPOINTS -> points in the X axis of the functions where the parts are
%                welded. It must be a vector with as many elements as
%                FUNPARTS minus 1, i.e., it includes as the last value the
%                value of X where the last function ends. 
% KPERC -> percentage of decay of the welding effect after we have moved 
%          1/5 of the corresponding function region starting at the transition
%          point. Usually, ~0.6. It must be > 0,  < 1.
% X -> point in X where to evaluate the resulting welded function.
%
% Y <- resulting value of the welded functions at X.
% W <- weight used for that welding or 0 if no welding done.

    w = 0;

    numparts = length(funparts);
    if numparts <= 0
        error('Invalid number of functions');
    end
    if (numparts == 1) || (x <= 0)
        y = funparts{1}(x);
        return;
    end
    if x > transpoints(end)
        y = funparts{end}(x);
        return;
    end
    if numparts ~= length(transpoints)
        error('Mismatch between the number of functions and the number of transition points');
    end

    if (kperc <= 0) || (kperc >= 1)
        error('Invalid kperc');
    end
    
    lensparts = transpoints(1:end) - [0,transpoints(1:end-1)];
    
    % set the middle of each function region as the point to begin welding
    % with another.
    midparts = [transpoints(1)/2, (transpoints(1:end-1) + transpoints(2:end))/2]; 

    % logistic function / sigmoid function for welding; goes from 0 to 1
    % smoothly, being 0.5 at the transition point.
    % the larger the K (positive), the more abrupt the transition
    % if we want that, after a distance of D from the transition point, the
    % function reaches ALPHA (e.g., 0.60) of its total weight, we can 
    % easily deduce that K > -ln(1/alpha - 1)/D
    transweight = @(x,k,transitionpoint) 1 ./ (1 + exp(-k * (x - transitionpoint)));
    % calculate K for having welding effects only around the transitionpoint
    disttofade = max(1,floor(min(lensparts)/5)); % distance from any transitionpoint where the welding effect should dissappear at 60%
    k = -log(1/kperc - 1) / disttofade;
    if k <= 0 % in this case any (positive) value of K is valid
        k = 1e-2;
    end
    % round k to the next upper number (fractional)
    kk = k;
    pot = -1;
    finish = 0;
    while ~finish
        kk = kk * 10;
        fkk = floor(kk);
        if fkk > 0
            k = (fkk + 1) * 10^pot; % ceil of the most significant fractional digit
            finish = 1;
        else
            pot = pot - 1;
        end
    end

    % curves to weld    
    if x <= midparts(1)
        parts = [1]; 
    elseif x > midparts(end)
        parts = [numparts];
    else
        for g = 1:numparts
            if x <= midparts(g) % cannot happen with g == 1
                parts = [g-1,g];
                transitionpoint = transpoints(g-1);
                break;
            end
        end
    end

    val1 = funparts{parts(1)}(x);
    if length(parts) == 1
        y = val1;
    else
        val2 = funparts{parts(2)}(x);   
        w = transweight(x,k,transitionpoint);
        y = val1 * (1 - w) + val2 * w;
    end


end