{
  function __v__(o) {
      if(Array.isArray(o)){
          for(var i = 0; i < o.length; i++){
              o[i] = __v__(o[i]);
          }
          return o;
      }else if(typeof o == 'function'){
          return o();
      }else if($.isPlainObject(o)){
          for(var x in o){
              if(o.hasOwnProperty(x)){
                  o[x] = __v__(o[x]);
              }
          }
          return o;
      }else{
          return o;
      }
  }
}

구문
= e:식*
{ return e.join(""); }

식
= 고정문자열
/ 표현식영역

고정문자열
= e:"\\{"
{ return e.charAt(1); }
/ e:"\\}"
{ return e.charAt(1); }
/ e:"\\"
{ return e.charAt(0); }
/ s:[^\\{}]+
{ 
	var result = s.join("");
	return result; 
}

표현식영역
= "{"  공백 e:표현식 공백 "}"
{ return __v__(e); }

표현식
= left:표현식요소 right:(공백 연산자 공백 표현식요소 공백 ":"? 공백 표현식요소?)*
{
    return function(){
        var op, result = __v__(left);
        if(right.length > 0){
            for(var i = 0; i < right.length; i++){
                op = right[i];
                switch(op[1]){
                    case "+":
                    result = result + __v__(op[3]);
                    break;
                    case "-":
                    result = result - __v__(op[3]);
                    break;
                    case "*":
                    result = result * __v__(op[3]);
                    break;              
                    case "/":
                    result = result / __v__(op[3]);
                    break;                            
                    case "<":
                    result = result < __v__(op[3]);
                    break;                                          
                    case ">":
                    result = result > __v__(op[3]);
                    break;   
                    case "==":
                    result = result == __v__(op[3]);
                    break;   
                    case "<=":
                    result = result <= __v__(op[3]);
                    break;   
                    case ">=":
                    result = result >= __v__(op[3]);
                    break;   
                    case "!=":
                    result = result != __v__(op[3]);
                    break;          
                    case "&&":
                    result = result && __v__(op[3]);
                    break;
                    case "||":
                    result = result || __v__(op[3]);
                    break;
                    case "===":
                    result = result === __v__(op[3]);
                    break;              
                    case "!==":
                    result = result !== __v__(op[3]);
                    break;               
                    case "?":
                    result = result ?  __v__(op[3]) :  __v__(op[7]);
                    break;
                }            
            }
        }
    	return result; 
    };

}

표현식요소
= e:표현식요소값 attrs:(함수/속성)*
{ 
    var self = this;
    return function(){
        var attr, result = e.type == 'gfn' ? window[__v__(e.name)].apply(window, __v__(e.params)) : __v__(e.value);
        if(self._.keymap){
            self._.keymap[__v__(e.name)] = self._.keymap[__v__(e.name)] ? self._.keymap[__v__(e.name)] + 1 : 1;
        }
        var path = __v__(e.name);
        if(attrs.length > 0){
            for(var i = 0; i < attrs.length; i++){
                attr = attrs[i];
                switch(attr.type){
                    case 'attr':
                    path = path + '.' + __v__(attr.name);
                    if(self._.keymap){
                        self._.keymap[path] = self._.keymap[path] ? self._.keymap[path] + 1 : 1;
                    }
                    result = result[__v__(attr.name)];
                    break;
                    case 'fn':
                    result = result[__v__(attr.name)].apply(result, __v__(attr.params));
                    break;
                }
            }
        }
        return result;
    };
}
/ 표현식_서브
/ 표현식_숫자

속성
= "." attr:식별자
{ 
	return { type: 'attr', name: attr }; 
}
/ "[" 공백 e:표현식 공백 "]"
{ return { type: 'attr', name: e }; }

표현식_전역함수
= fn:식별자 공백 "(" 공백 p:파라미터? 공백 ")"
{ return { type: 'gfn', name: fn, params: p }; }

함수
= attr:속성 공백 "(" 공백 p:파라미터? 공백 ")"
{ return { type: 'fn', name: attr.name, params: p }; }

표현식요소값
= 표현식_문자열
/ 표현식_배열
/ 표현식_전역함수
/ 표현식_변수
/ 표현식_객체



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

표현식_배열
= "[" 공백 e:표현식 es:(공백 "," 공백 표현식)* 공백 "]"
{
    var arr = [e];
    for(var i = 0; i < es.length; i++){
    	arr.push(es[i][3]);
    }
	return { type: 'array', value: arr };
}

표현식_객체
= "{" 공백 p1:식별자 공백 ":" 공백 v1:표현식 공백 ps:(공백 "," 공백 식별자 공백 ":" 공백 표현식 공백)* 공백 "}"
{
	var obj = {};
    obj[typeof p1 == 'object' ? p1.value : p1 ] = v1;
    for(var i = 0; i < ps.length; i++){
    	obj[ps[i][3]] = ps[i][7];
    }
	return { type: 'object', name: 'anonymous', value: obj };
}

표현식_서브
= "("  공백 e:표현식 공백 ")"
{ return e; }


식별자
= w:[a-zA-Zㄱ-힣_$] w2:[a-zA-Zㄱ-힣0-9_]*
{
	return w + w2.join("");
}


키워드
= "true"
{ 
	return { type: 'keyword', value:true };
}
/ "false"
{ 
	return { type: 'keyword', value: false };
}
/ "N"
{ 
	return { type: 'keyword', value: this.N };
}
/ "Math"
{ 
	return { type: 'keyword', value: Math };
}
/ "$"
{ 
	return { type: 'keyword', value: this.$ };
}
/ "jQuery"
{ 
	return { type: 'keyword', value: this.$ };
}
/ "window"
{ 
	return { type: 'keyword', value: window };
}
/ "Math"
{ 
	return { type: 'keyword', value: Math }; 
}
/ "JSON"
{ 
	return { type: 'keyword', value: JSON }; 
}
/ "this"
{
    return { type: 'keyword', value: this.context };
}
/ "_"
{
    return { type: 'keyworld', value: this._ };
}


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
= sign:[\-]? n1:[0-9]+ dot:"."? n2:[0-9]*
{ 
	var num = Number(n1.join("") + (dot ? "." : "") + (n2 ? n2.join("") : ""), 10);
    if(sign){
        num = -num; 
    }
	return num
}


표현식_문자열
= "\"" s:[^"]* "\""
{ 
	return { type: 'literal', value: s.join("") }; 
}
/ "\'" s:[^']* "\'"
{ 
	return { type: 'literal', value: s.join("") }; 
}

표현식_변수
= 키워드
/ e:식별자
{ 
	return { type: 'property', value: this.context[e], name: e };
}