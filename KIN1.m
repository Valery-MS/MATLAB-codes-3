%________ опр КИ-ла при движ вПраво. nm1 = 1 ______
function x0 = KIN1(n,c,e1,e3,T2,V2,x0,ah,bn,HF,VF,f)           
global eps10                          
% HF(x0(1))*HF(x0(2)) > 0
% ТСВ5-1
% 1. Найден  КИН => х0 = КИН,  
% 3. Не найд КИН => x0 = В направлении  0 корня нет 
% 4. Не найд КИН => x0 = В направлении VF корня нет 
% if KIN1 исп-ся в SolvR,  VF = Ve,
% else   (исп-ся в SolvL), VF = Xfa, 

% figure;a_=x0(1);b_=x0(2);h_=(b_-a_)/100;x_=(a_:h_:b_)';y_=HF(n,c,e1,e3,T2,V2,x_,ah,bv);plot(x_,y_);title(sprintf('x0=%g %g',x0));grid
fA = f(1);   fB = f(2);   fAB = fA-fB;
A  = x0(1);  B  = x0(2);  BA  = B-A;
ff = fA/fAB;

if fA > 0  
   h  = BA*ff;
   xp = A+h;  x = xp+h;
   if x > 0
      if HF( n, c, e1,e3, T2, V2, x, ah,bn)*fA < 0
         x0 = [x; A];   return
      end
   elseif HF( n, c, e1,e3, T2, V2, eps10, ah,bn)*fA < 0
         x0 = [eps10; xp];  return
   else  x0 = 'В направлении 0 корня нет';  return    
   end
     
   xp = x;  x = x+h;
   while x > 0 
      if HF( n, c, e1,e3, T2, V2, x, ah,bn)*fA < 0
         x0 = [x; xp];  return
      end
      xp = x;  x = x+h; h = h+h;
   end 
   
   if HF( n, c, e1,e3, T2, V2, eps10, ah,bn)*fA < 0
          x0 = [eps10; x-h]; 
   else   x0  = 'В направлении 0 корня нет';      
   end
   return
else
   h  = BA*fB/fAB;
   xp = B+h;  x = xp+h;
   if x < VF
      if HF( n, c, e1,e3, T2, V2, x, ah,bn)*fA < 0
         x0 = [B; x];  return
      end
   elseif HF( n, c, e1,e3, T2, V2, VF, ah,bn)*fA < 0
         x0 = [B; VF];    return
   else  x0  = 'В направлении VF корня нет';  return
   end
   
   xp = x;  x = x+h;
   while x < VF 
      if HF( n, c, e1,e3, T2, V2, x, ah,bn)*fA < 0
         x0 = [x; xp];  return
      end
      xp = x;  x = x+h;  h = h+h;
   end
   
   if HF( n, c, e1,e3, T2, V2, VF, ah,bn)*fA < 0
         x0 = [xp; VF]; 
   else  x0  = 'В направлении VF корня нет';                
   end
   return   
end