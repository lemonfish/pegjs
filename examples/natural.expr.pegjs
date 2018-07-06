구문
= e:식*
{ return e.join(""); }

식
= 표현식영역
/ 고정문자열

고정문자열
= s:[^{}]+
{ 
	var result = s.join("");
	return result; 
}
/ "{{"
{ return e.charAt(0); }
/ e:"}}"
{ return e.charAt(0); }

표현식영역
= "{"  공백 e:표현식 공백 "}"
{ return e; }

표현식
= left:표현식요소 right:(공백 연산자 공백 표현식요소 공백 ":"? 공백 표현식요소?)*
{ 
	var op, result = left;
    if(right.length > 0){
		for(var i = 0; i < right.length; i++){
          op = right[i];
          switch(op[1]){
              case "+":
              result = result + op[3];
              break;
              case "-":
              result = result - op[3];        
              break;
              case "*":
              result = result * op[3];        
              break;              
              case "/":
              result = result / op[3];
              break;                            
              case "<":
              result = result < op[3];
              break;                                          
              case ">":
              result = result > op[3];
              break;   
              case "==":
              result = result == op[3];
              break;   
              case "<=":
              result = result <= op[3];
              break;   
              case ">=":
              result = result >= op[3];
              break;   
              case "!=":
              result = result != op[3];
              break;          
              case "&&":
              result = result && op[3];
              break;
              case "||":
              result = result || op[3];
              break;
              case "===":
              result = result === op[3];
              break;              
              case "!==":
              result = result !== op[3];
              break;               
              case "?":
              result = result ? op[3] : op[7];
              break;
          }            
        }
    }
	return result; 
}

표현식요소
= e:표현식요소값 attrs:(함수/속성)*
{ 
	var attr, result = e;
    if(attrs.length > 0){
    	for(var i = 0; i < attrs.length; i++){
        	attr = attrs[i];
            switch(attr.type){
            	case 'attr':
                result = result[attr.name];
                break;
                case 'fn':
                result = result[attr.name].apply(result, attr.params);
                break;
            }
        }
    }
    return result;
}
/ 표현식_서브
/ 표현식_숫자

속성
= "." attr:식별자
{ return { type: 'attr', name: attr }; }
/ "[" 공백 e:표현식 공백 "]"
{ return { type: 'attr', name: e }; }

표현식_전역함수
= fn:식별자 공백 "(" 공백 p:파라미터* 공백 ")"
{ return window[fn].apply(window, p); }

함수
= attr:속성 공백 "(" 공백 p:파라미터* 공백 ")"
{ return { type: 'fn', name: attr.name, params: p }; }

표현식요소값
= 표현식_문자열
/ 표현식_전역함수
/ 표현식_변수



파라미터 
= p:표현식 ps:(공백 "," 공백 표현식)*
{
	var params = [];
    params.push(p);
    for(var i = 0; i < ps.length; i++){
    	params.push(ps[i][3]);
    }
    
    return params;
}


표현식_서브
= "("  공백 e:표현식 공백 ")"
{ return e; }


식별자
= w:[a-zA-Zㄱ-힣_] w2:[a-zA-Zㄱ-힣0-9_]*
{
	return w + w2.join("");
}


키워드
= "true"
{ return true; }
/ "false"
{ return false; }
/ "N"
{ return N; }
/ "Math"
{ return Math; }

공백
= [\t\n ]*

연산자
= "==="
/ "!=="
/ "=="
/ "!="
/ "<="
/ ">="
/ "&&"
/ "||"
/ "+"
/ "-"
/ "*"
/ "/"
/ "<"
/ ">"
/ "?"


표현식_숫자
= n1:[0-9]+ dot:"."? n2:[0-9]*
{ 
	var num = Number(n1.join("") + (dot ? "." : "") + (n2 ? n2.join("") : ""), 10);
	return num
}


표현식_문자열
= "\"" s:[^"]* "\""
{ 
	return s.join(""); 
}
/ "\'" s:[^']* "\'"
{ 
	return s.join(""); 
}

표현식_변수
= 키워드
/ e:식별자
{ return this[e]; }

