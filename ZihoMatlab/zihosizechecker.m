%zihosizechecker

myvarszihosizechecker=who;


for kzihosizechecker=1:length(myvarszihosizechecker)
    
    sizek(kzihosizechecker,:) = size(kzihosizechecker);
    
    rowzihosizechecker(kzihosizechecker,:)=[myvarszihosizechecker(kzihosizechecker) sizek(kzihosizechecker,:)];
    
end

printoutziho(rowzihosizechecker)