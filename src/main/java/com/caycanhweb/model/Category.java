package com.caycanhweb.model;

public class Category {
    private int    categoryId;
    private String name;
    private String slug;
    private String description;
    private String imageUrl;

    public Category() {}

    public Category(int categoryId, String name, String slug) {
        this.categoryId  = categoryId;
        this.name        = name;
        this.slug        = slug;
    }

    public int    getCategoryId()  { return categoryId; }
    public void   setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public String getName()        { return name; }
    public void   setName(String name) { this.name = name; }
    public String getSlug()        { return slug; }
    public void   setSlug(String slug) { this.slug = slug; }
    public String getDescription() { return description; }
    public void   setDescription(String description) { this.description = description; }
    public String getImageUrl()    { return imageUrl; }
    public void   setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}