global class CustomIterator implements Iterator<sObject>{ 

    List<sObject> objects {get;set;} 
    Integer i {get;set;} 
    
    public CustomIterator(List<sObject> objs)
    {
        objects = objs;
        i = 0; 
    }
    
    global boolean hasNext()
    { 
       if(i >= objects.size()) {
           return false; }
       else {
           return true; }
    }
    
    global sObject next()
    { 
        if(!hasNext()){ i++; return null;} 
        i=i+1; 
        return objects[i-1]; 
    }
}