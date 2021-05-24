global class CustomIterable implements Iterable<sObject>
{
    List<sObject> objects {get;set;}
    
    global CustomIterable(List<sObject> objs)
    {
        objects = objs;
    }

    global Iterator<sObject> Iterator()
    {
        return new CustomIterator(objects);
    }
}