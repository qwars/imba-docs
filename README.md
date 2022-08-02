# imba-docs
Imba document parser

## Structure

```
    [comment(###)]
    @tags - name as (tag|class)|name(tag|class)|.....|name(tag|class)
    [comment(###)]

```

Prop 

```
    [comment(#)] @prop/{ type or name(tag|class) } - { display name }
    
    [comment(###)]
    @prop/{ type or name(tag|class) } 
        - { display name }
        - { display desctiption }
    [comment(###)] 

    [comment(###)] 
    @prop/{ type or name(tag|class) } 
        - { display name }
    [comment(###)]
    [comment(#)] { display desctiption }
    
    [comment(###)]
    @prop/{ type or name(tag|class) } 
        - { display name }
    [comment(###)]
    [comment(###)] 
    { display desctiption }
    [comment(###)]
    
```

Event or Method

```
    [comment(#)] @{ event|method } - { display name }
    [comment(#)] @{ event|method }/@TAG - { display name }
    [comment(###)]
    @{ event|method }:
        { prop number }/{ type or name(tag|class) }
            - { display name }
            - { display desctiption }
        - { display name }
        - { display desctiption }
        { prop number }/{ type or name(tag|class) }
            - { display name }
            - { display desctiption }
    [comment(###)]

    [comment(###)]
    @{ event|method }/@tag: 
        - { display name }
        { prop number or name }/{ type or name(tag|class) }
            - { display name }
            - { display desctiption }
    [comment(###)]
    [comment(#)] { display desctiption }
    
    [comment(###)]
    @{ event|method }:
        { prop number or name }/{ type or name(tag|class) }
            - { display name }
            - { display desctiption }
        - { display name }
    [comment(###)]
    [comment(###)] 
    { display desctiption }
    [comment(###)]
    
```

```
###
    @props:
        {name}/{ type or name(tag|class) }
            - { display name }
            - { display desctiption }
###
prop {name} default: 'Yes'

###
    @{ events|methods }:
        {name}/@TAG:
            { prop number - $n }/{ type or name(tag|class) }
                - { display name }
                - { display desctiption }
            - { display name }
            - { display desctiption }
            { prop number - $n }/{ type or name(tag|class) }
                - { display name }
                - { display desctiption }
###

def {name} a, b
    self
    

```


**TODO:**

```
    [comment(#)] @tag extend name(tag|class) 
```
