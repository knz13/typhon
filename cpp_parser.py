import os
import re


os.chdir("c_sharp_interface/src")

files = []

for file in os.listdir("."):
    if file.endswith(".h"):
        files.append(file)

def getClassesText(text):
    #removing comments
    matches = re.findall("/\*.*?\*/",text)
    matches += re.findall("//.*?\n",text)
    for i in matches:
        text = text.replace(i,"")

    
    

    classes = {}
    class_names = [m.start() for m in re.finditer("class .*? {",text)]
    class_names += [m.start() for m in re.finditer("class .*? :",text)]
    class_names = list(map(lambda x: (text[x + len("class "):].split()[0],text[x:].find("{") + x - 1),class_names))
    
    classes_text = {}
    for i,data in enumerate(class_names):
        class_name,class_start = data

        initial_position = class_start
        end_position = -1
        if i == len(class_names) -1:
            end_position = len(text) - 1
        else:
            end_position = class_names[i+1][1]

        class_text = text[initial_position + 1:end_position]    
        
        scope_starts = [(m.start(),"open") for m in re.finditer("{",class_text)]
        scope_ends = [(m.start(),"close") for m in re.finditer("}",class_text)]
        
        scopes = sorted(scope_starts + scope_ends,key=lambda x : x[0])
        end_scope = 0
        final_position = -1
        scopes_opened = 0
        for end_scope in range(len(scopes)):
            if scopes[end_scope][1] == "open":
                scopes_opened += 1
            if scopes[end_scope][1] == "close":
                if scopes_opened == 1:
                    final_position = scopes[end_scope][0]
                    break
                
                scopes_opened -= 1

        class_text = class_text[:final_position + 1]

        classes_text[class_name] = class_text

    return classes_text

    

def extractVariableFromClasses(classes):
    class_variables = {}

    for class_name in classes:
        class_text = classes[class_name]

        variables = []


        #positions_from_function_starts = [m.start() + m.group(0).find("{") for m in re.finditer(r"(?s:.*?) (?s:.*?)\((?s:.*?)\)(?s:.*?){(?s:.*)}",class_text[1:-1])]
        #positions_inside_strings = [m.start() for m in re.finditer('".*{.*"',class_text[1:-1])]
        #positions_from_function_starts = list(filter(lambda x: x not in positions_inside_strings,positions_from_function_starts))
        #removing function names
        class_text = class_text.replace("\n","")
        friends = re.findall("friend.*?;",class_text)
        for i in friends:
            class_text = class_text.replace(i,"")

        variables = re.findall(r'\b(?:const\s+)?[\w:]+(?:<.*?>)?\s+[\*&]?\w+\s*(?:=[^;]+)?;',class_text)

        print(variables)
        break

        print("-"*100)
        print()
        print(class_text)
        print()
        print("-"*100)

       
        #print("-"*100)
        #print(f'{class_text}')
        #print("-"*100)


        #print(class_text)
    return class_variables
        

classes = []

for file in files:
    with open(file,'r') as f:
        text = f.read()
        
        classes = getClassesText(text)

        classes_with_variables = extractVariableFromClasses(classes)

        



               


