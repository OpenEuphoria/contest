-- misceval.e
-- Miscelaneous math routines
-- version 1.01 6/15/00
-- Matt Lewis matthewlewis@hotmail.com
--
-- version 1.01
-- Added RemoveOne for slicing sequences.

global function IsEven( atom a )
    return (remainder(a, 2) = 0 ) * ( a > 0 )
end function


global function RemoveOne( sequence a, integer i) 

    return a[1..i-1] & a[i+1..length(a)]
    
end function


global function min_pos_ix( sequence a )
    for i = 1 to length(a) do
        if a[i] > 0 then
            return i
        end if
    end for
    return 0
end function


